import AVFoundation
import UIKit

// swiftlint:disable file_length
public class KinescopeVideoPlayer: KinescopePlayer {

    // MARK: - Private Properties

    private let dependencies: KinescopePlayerDependencies
    private lazy var strategy: PlayingStrategy = {
        dependencies.provide(for: config)
    }()

    private weak var view: KinescopePlayerView?

    private var timeObserver: Any?
    private var playerStatusObserver: NSKeyValueObservation?
    private var itemStatusObserver: NSKeyValueObservation?
    private var timeControlStatusObserver: NSKeyValueObservation?
    private var tracksObserver: NSKeyValueObservation?

    private var isSeeking = false
    private var isManualQuality = false
    private var currentQuality = ""
    private var currentTime: CMTime = .zero
    private var isPlaying = false
    private var isOverlayed = false
    private weak var miniView: KinescopePlayerView?

    private var video: KinescopeVideo?
    private let config: KinescopePlayerConfig
    private var options = [KinescopePlayerOption]()

    private var textStyleRules: [AVTextStyleRule]? {
        let pos = kCMTextMarkupAttribute_OrthogonalLinePositionPercentageRelativeToWritingDirection
        guard
            let rule = AVTextStyleRule(
                textMarkupAttributes: [
                    pos as String: 75.0,
                    kCMTextMarkupAttribute_BaseFontSizePercentageRelativeToVideoHeight as String: 10.0
                ]
            )
        else {
            return nil
        }

        return [rule]
    }

    // MARK: - Lifecycle

    init(config: KinescopePlayerConfig, dependencies: KinescopePlayerDependencies) {
        self.dependencies = dependencies
        self.config = config

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(changeOrientation),
                                               name: UIDevice.orientationDidChangeNotification,
                                               object: nil)
    }

    deinit {
        self.removePlaybackTimeObserver()
        self.removePlayerItemStatusObserver()
        self.removePlayerTimeControlStatusObserver()
        self.removePlayerStatusObserver()
        self.removeTracksObserver()

        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - KinescopePlayer

    public required convenience init(config: KinescopePlayerConfig) {
        self.init(config: config, dependencies: KinescopeVideoPlayerDependencies())
    }

    public func play() {
        if video != nil {
            self.strategy.play()
        } else {
            self.load()
        }
    }

    public func pause() {
        self.strategy.pause()
    }

    public func stop() {
        self.strategy.pause()
        self.strategy.unbind()
        self.removeTracksObserver()
    }

    public func attach(view: KinescopePlayerView) {
        view.playerView.player = self.strategy.player
        view.delegate = self
        self.view = view
        view.set(options: options)

        observePlaybackTime()
        addPlayerTimeControlStatusObserver()
        addPlayerStatusObserver()
    }

    public func detach(view: KinescopePlayerView) {
        view.playerView.player = nil
        self.view = nil
        view.delegate = nil

        removePlaybackTimeObserver()
        removePlayerTimeControlStatusObserver()
        removePlayerStatusObserver()
    }

    public func select(quality: KinescopeVideoQuality) {
        guard let item = quality.item else {
            // Log here critical error
            return
        }

        switch quality {
        case .auto:
            isManualQuality = false
        case .exact, .exactWithSubtitles, .downloaded:
            isManualQuality = true
        }

        currentTime = strategy.player.currentTime()

        removeTracksObserver()
        removePlayerItemStatusObserver()

        strategy.bind(item: item)

        addPlayerItemStatusObserver()
        addTracksObserver()
    }
}

// MARK: - Private

private extension KinescopeVideoPlayer {

    /// Sends request video by id and sets player's item
    func load() {
        view?.startLoader()

        dependencies.inspector.video(
            id: config.videoId,
            onSuccess: { [weak self] video in
                self?.video = video
                self?.select(quality: .auto(hlsLink: video.hlsLink))
                self?.view?.overlay?.set(title: video.title, subtitle: video.description)
                self?.view?.set(options: self?.makePlayerOptions(from: video) ?? [])
                self?.play()
            },
            onError: { [weak self] error in
                self?.view?.stopLoader()
                Kinescope.shared.logger?.log(error: error, level: KinescopeLoggerLevel.network)
            }
        )
    }

    func makePlayerOptions(from video: KinescopeVideo) -> [KinescopePlayerOption] {
        var options: [KinescopePlayerOption] = [.airPlay, .download, .settings, .fullscreen, .more]

        if !video.additionalMaterials.isEmpty {
            options.insert(.attachments, at: 0)
        }

        if !video.subtitles.isEmpty {
            options.insert(.subtitles, at: 0)
        }

        self.options = options
        return options
    }

    func observePlaybackTime() {
        guard view?.controlPanel != nil else {
            return
        }

        let timeScale = CMTimeScale(NSEC_PER_SEC)
        let period = CMTimeMakeWithSeconds(0.05, preferredTimescale: timeScale)

        timeObserver = strategy.player.addPeriodicTimeObserver(forInterval: period,
                                                               queue: .main) { [weak self] time in
            let isSeeking = self?.isSeeking ?? false

            /// Do not update timeline and indicator value when seeking to new position
            guard !isSeeking else {
                return
            }

            /// Does not make sense without control panel and curremtItem
            guard let controlPanel = self?.view?.controlPanel,
                  let currentItem = self?.strategy.player.currentItem else {
                return
            }

            // MARK: - Current time observation

            let time = time.seconds

            Kinescope.shared.logger?.log(message: "playback position changed to \(time) seconds", level: KinescopeLoggerLevel.player)

            if !time.isNaN {
                controlPanel.setIndicator(to: time)
            }

            let duration = currentItem.duration.seconds

            let position = CGFloat(time / duration)
            if !position.isNaN {
                controlPanel.setTimeline(to: position)
            }

            // MARK: - Preload observation

            let buferredTime = currentItem.loadedTimeRanges.first?.timeRangeValue.end.seconds ?? 0

            Kinescope.shared.logger?.log(message: "playback buffered \(buferredTime) seconds", level: KinescopeLoggerLevel.player)

            let bufferProgress = CGFloat(buferredTime / duration)

            if !bufferProgress.isNaN {
                controlPanel.setBufferred(progress: bufferProgress)
            }
        }
    }

    func removePlaybackTimeObserver() {
        if let timeObserver = timeObserver {
            strategy.player.removeTimeObserver(timeObserver)
            self.timeObserver = nil
        }
    }

    func addPlayerStatusObserver() {
        self.playerStatusObserver = self.strategy.player.observe(
            \.status,
            options: [.new, .old],
            changeHandler: { [weak self] item, _ in
                self?.view?.change(status: item.status)

                Kinescope.shared.logger?.log(message: "AVPlayer.Status – \(item.status)",
                                             level: KinescopeLoggerLevel.player)
            }
        )
    }

    func removePlayerStatusObserver() {
        self.playerStatusObserver?.invalidate()
        self.playerStatusObserver = nil
    }

    func addPlayerItemStatusObserver() {
        self.itemStatusObserver = self.strategy.player.currentItem?.observe(
            \.status,
            options: [.new, .old],
            changeHandler: { [weak self] item, _ in
                guard
                    let self = self
                else {
                    return
                }

                switch item.status {
                case .readyToPlay:
                    if self.currentTime.seconds > .zero {
                        self.seek(to: self.currentTime.seconds)
                        self.currentTime = .zero
                    }
                case .failed, .unknown:
                    Kinescope.shared.logger?.log(message: "AVPlayerItem.error – \(String(describing: item.error))",
                                                 level: KinescopeLoggerLevel.player)
                default:
                    break
                }

                Kinescope.shared.logger?.log(message: "AVPlayerItem.Status – \(item.status)",
                                             level: KinescopeLoggerLevel.player)
            }
        )
    }

    func removePlayerItemStatusObserver() {
        self.itemStatusObserver?.invalidate()
        self.itemStatusObserver = nil
    }

    func addPlayerTimeControlStatusObserver() {
        self.timeControlStatusObserver = self.strategy.player.observe(
            \.timeControlStatus,
            options: [.new, .old],
            changeHandler: { [weak self] item, _ in
                self?.isPlaying = item.timeControlStatus == .playing
                self?.view?.change(timeControlStatus: item.timeControlStatus)

                Kinescope.shared.logger?.log(
                    message: "AVPlayer.TimeControlStatus – \(item.timeControlStatus.rawValue)",
                    level: KinescopeLoggerLevel.player
                )
            }
        )
    }

    func removePlayerTimeControlStatusObserver() {
        self.timeControlStatusObserver?.invalidate()
        self.timeControlStatusObserver = nil
    }

    func addTracksObserver() {
        self.tracksObserver = self.strategy.player.currentItem?.observe(
            \.tracks,
            options: [.new, .old],
            changeHandler: { [weak self] item, _ in
                guard
                    let self = self,
                    let video = self.video,
                    let size = item.tracks.first?.assetTrack?.naturalSize,
                    let frameRate = item.tracks.first?.assetTrack?.nominalFrameRate
                else {
                    return
                }

                let height = String(format: "%.0f", size.height)

                let qualities = video.assets
                    .compactMap { $0.quality }
                    .filter { $0.hasPrefix(height) }

                let expectedQuality: String?
                if frameRate > 30.0 {
                    expectedQuality = qualities.first { $0.hasSuffix("60") }
                } else {
                    expectedQuality = qualities.first { $0.hasPrefix(height) && !$0.hasSuffix("60") }
                }

                guard
                    let quality = expectedQuality
                else {
                    return
                }

                self.view?.change(quality: quality, manualQuality: self.isManualQuality)

                Kinescope.shared.logger?.log(
                    message: "AVPlayerItem.presentationSize – \(item.presentationSize)",
                    level: KinescopeLoggerLevel.player
                )
            }
        )
    }

    func removeTracksObserver() {
        self.tracksObserver?.invalidate()
        self.tracksObserver = nil
    }

    func seek(to seconds: TimeInterval) {
        let time = CMTime(seconds: seconds, preferredTimescale: CMTimeScale(NSEC_PER_SEC))

        Kinescope.shared.logger?.log(message: "timeline changed to \(seconds) seconds",
                                     level: KinescopeLoggerLevel.player)

        isSeeking = true
        strategy.player.seek(to: time, toleranceBefore: .zero, toleranceAfter: time) { [weak self] _ in
            self?.isSeeking = false
        }

        // Update view because periodicTimeObserver won't trigger if current second of video didn't downloaded
        // Also when video is seeking, periodicTimeObserver won't update the view
        let duration = strategy.player.currentItem?.duration.seconds ?? .zero
        let position = CGFloat(seconds / duration)
        if !position.isNaN {
            view?.controlPanel?.setTimeline(to: CGFloat(position))
        }
        if !seconds.isNaN {
            view?.controlPanel?.setIndicator(to: seconds)
        }
    }

    @objc
    func changeOrientation() {
        guard
            let view = view,
            view.canBeFullScreen
        else {
            return
        }

        let isFullScreen = UIApplication.shared.keyWindow?.rootViewController?.presentedViewController is KinescopeFullscreenViewController

        if UIDevice.current.orientation.isLandscape && !isFullScreen {
            didPresentFullscreen(from: view)
        } else if !UIDevice.current.orientation.isLandscape && isFullScreen {
            didPresentFullscreen(from: view)
        }
    }

    func restoreView() {
        view?.showOverlay(isOverlayed)
        isPlaying ? play() : pause()
    }

}

// MARK: - KinescopePlayerViewDelegate

extension KinescopeVideoPlayer: KinescopePlayerViewDelegate {

    func didPlay(videoEnded: Bool) {
        if videoEnded {
            self.strategy.player.seek(to: .zero)
        }

        self.play()
    }

    func didPause() {
        self.pause()
    }

    func didSeek(to position: Double) {

        guard let duration = strategy.player.currentItem?.duration.seconds else {
            return
        }

        Kinescope.shared.logger?.log(message: "timeline changed to \(position)",
                                     level: KinescopeLoggerLevel.player)

        let seconds = position * duration
        seek(to: seconds)
    }

    func didSelect(option: KinescopePlayerOption) {
    }

    func didFastForward() {
        let currentTime = strategy.player.currentTime().seconds

        guard
            let duration = strategy.player.currentItem?.duration.seconds
        else {
            return
        }

        Kinescope.shared.logger?.log(message: "fast forward +15s", level: KinescopeLoggerLevel.player)

        let seconds = currentTime + 15.0
        if seconds < duration {
            seek(to: seconds)
        } else {
            seek(to: duration)
        }
    }

    func didFastBackward() {
        let currentTime = strategy.player.currentTime().seconds

        Kinescope.shared.logger?.log(message: "fast backward -15s", level: KinescopeLoggerLevel.player)

        let seconds = currentTime - 15.0
        if seconds > .zero {
            seek(to: seconds)
        } else {
            seek(to: .zero)
        }
    }

    func didPresentFullscreen(from view: KinescopePlayerView) {
        let rootVC = UIApplication.shared.keyWindow?.rootViewController

        if rootVC?.presentedViewController is KinescopeFullscreenViewController {
            isOverlayed = view.overlay?.isSelected ?? false
            detach(view: view)

            rootVC?.dismiss(animated: true, completion: { [weak self] in
                guard
                    let self = self,
                    let miniView = self.miniView
                else {
                    return
                }

                self.attach(view: miniView)
                self.view?.change(quality: self.currentQuality, manualQuality: self.isManualQuality)
                self.restoreView()
            })
        } else {
            miniView = view
            isOverlayed = view.overlay?.isSelected ?? false

            detach(view: view)

            let playerVC = KinescopeFullscreenViewController(player: self,
                                                             config: .preferred(for: video))
            playerVC.modalPresentationStyle = .overFullScreen
            playerVC.modalTransitionStyle = .crossDissolve
            rootVC?.present(playerVC, animated: true, completion: { [weak self] in
                guard
                    let self = self,
                    let video = self.video
                else {
                    return
                }

                self.view?.change(status: .readyToPlay)
                self.view?.change(quality: self.currentQuality, manualQuality: self.isManualQuality)
                self.view?.overlay?.set(title: video.title, subtitle: video.description)
                self.restoreView()
            })
        }
    }

    func didShowQuality() -> [String] {
        return video?.assets
            .compactMap { $0.quality }
            .filter { $0 != "original" } ?? []
    }

    func didShowAttachments() -> [KinescopeVideoAdditionalMaterial]? {
        return video?.additionalMaterials
    }

    func didShowAssets() -> [KinescopeVideoAsset]? {
        return video?.downloadableAssets
    }

    func didSelect(quality: String) {
        guard
            let video = video
        else {
            Kinescope.shared.logger?.log(message: "Can't find video",
                                         level: KinescopeLoggerLevel.player)
            return
        }

        let videoQuality: KinescopeVideoQuality
        if let asset = video.assets.first(where: { $0.quality == quality }) {
            if let path = dependencies.assetDownloader.getLocation(by: asset.id) {
                videoQuality = .downloaded(url: path)
            } else {
                videoQuality = .exact(asset: asset)
            }
        } else {
            videoQuality = .auto(hlsLink: video.hlsLink)
        }

        currentQuality = quality

        select(quality: videoQuality)

        Kinescope.shared.logger?.log(message: "Select quality: \(quality)",
                                     level: KinescopeLoggerLevel.player)
    }

    func didSelectAttachment(with index: Int) {
        guard
            let attachment = video?.additionalMaterials[safe: index]
        else {
            return
        }
        dependencies.attachmentDownloader.enqueueDownload(attachment: attachment)
        Kinescope.shared.logger?.log(message: "Start downloading attachment: \(attachment.title)",
                                     level: KinescopeLoggerLevel.player)
    }

    func didSelectAsset(with index: Int) {
        guard let asset = video?.assets[safe: index] else {
            return
        }
        dependencies.assetDownloader.enqueueDownload(asset: asset)
        Kinescope.shared.logger?.log(message: "Start downloading asset: \(asset.id + asset.originalName)",
                                     level: KinescopeLoggerLevel.player)
    }

    func didSelectDownloadAll(for title: String) {
        switch title {
        case SideMenu.DescriptionTitle.download.rawValue:
            video?.downloadableAssets.forEach {
                dependencies.assetDownloader.enqueueDownload(asset: $0)
                Kinescope.shared.logger?.log(message: "Start downloading asset: \($0.quality) - \($0.id)",
                                             level: KinescopeLoggerLevel.player)
            }
        case SideMenu.DescriptionTitle.attachments.rawValue:
            video?.additionalMaterials.forEach {
                dependencies.attachmentDownloader.enqueueDownload(attachment: $0)
                Kinescope.shared.logger?.log(message: "Start downloading attachment: \($0.title)",
                                             level: KinescopeLoggerLevel.player)
            }
        default:
            break
        }
    }

    func didShowSubtitles() -> [String] {
        return video?.subtitles.compactMap { $0.title } ?? []
    }

    func didSelect(subtitles: String) {
        guard
            let video = video
        else {
            Kinescope.shared.logger?.log(message: "Can't find video",
                                         level: KinescopeLoggerLevel.player)
            return
        }

        if isManualQuality {
            guard
                let asset = video.assets.first(where: { $0.quality == currentQuality })
            else {
                return
            }

            let videoQuality: KinescopeVideoQuality
            if let selectedSubtitles = video.subtitles.first(where: { $0.title == subtitles }) {
                videoQuality = .exactWithSubtitles(asset: asset, subtitle: selectedSubtitles)
            } else {
                videoQuality = .exact(asset: asset)
            }

            select(quality: videoQuality)
        } else {
            guard
                let item = self.strategy.player.currentItem,
                let group = item.asset.mediaSelectionGroup(forMediaCharacteristic: .legible)
            else {
                return
            }

            if let selectedSubtitles = video.subtitles.first(where: { $0.title == subtitles }) {
                let locale = Locale(identifier: selectedSubtitles.language)
                let options = AVMediaSelectionGroup.mediaSelectionOptions(from: group.options,
                                                                          with: locale)
                self.strategy.player.currentItem?.select(options.first, in: group)
            } else {
                self.strategy.player.currentItem?.select(nil, in: group)
            }
        }

        self.strategy.player.currentItem?.textStyleRules = textStyleRules

        let isOn = video.subtitles.contains { $0.title == subtitles }
        view?.controlPanel?.set(subtitleOn: isOn)
        Kinescope.shared.logger?.log(message: "Select subtitles: \(subtitles)",
                                     level: KinescopeLoggerLevel.player)
    }

}
// swiftlint:enable file_length
