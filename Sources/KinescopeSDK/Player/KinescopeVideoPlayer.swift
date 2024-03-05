import AVFoundation
import AVKit
import UIKit

public class KinescopeVideoPlayer: KinescopePlayer, KinescopePlayerBody {

    public weak var pipDelegate: AVPictureInPictureControllerDelegate? {
        didSet {
            view?.pipController?.delegate = pipDelegate
        }
    }

    // MARK: - Private Properties
    
    private let config: KinescopePlayerConfig
    private let dependencies: KinescopePlayerDependencies

    private let kvoBag = KVOBag()

    private lazy var notificationsBag = NotificationsBag(observer: self)
    
    @Repeating(executionQueue: .main, attemptsLimit: 10, intervalSeconds: 5)
    private var playRepeater

    private(set) lazy var strategy: PlayingStrategy = {
        dependencies.provide(for: config)
    }()
    private lazy var innerEventsHandler: InnerEventsHandler = {
        let service = AnalyticsNetworkService(transport: Transport(), config: Kinescope.shared.config)
        return InnerEventsProtoHandler(service: service)
    }()

    private(set) weak var view: KinescopePlayerView?

    private var time: TimeInterval = 0 {
        didSet {
            updateTimeline()
        }
    }
    private(set) var isLive = false {
        didSet {
            updateLiveIndicator()
        }
    }

    private var isSeeking = false
    private var isPreparingSeek = false
    private var currentQuality = ""
    private var isPlaying = false
    private var isOverlayed = false
    private var savedTime: CMTime = .zero
    private weak var miniView: KinescopePlayerView?
    private(set) weak var delegate: KinescopeVideoPlayerDelegate?

    private var drmHandler: DataProtectionHandler?
    private var video: KinescopeVideo? {
        didSet {
            guard let video else {
                return
            }
            isLive = video.type == .live
            drmHandler = dependencies.drmFactory.provide(for: video.id)
        }
    }
    private var options = [KinescopePlayerOption]()
    
    private var playbackObserverFactory: (any Factory)?
    private var playbackObserver: Any?

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
        playRepeater = .init(title: "play") { [weak self] in self?.play() }
        addNotofications()
    }

    deinit {
        self.removePlaybackTimeObserver()
        self.kvoBag.removeAll()
        self.notificationsBag.removeAll()
    }

    // MARK: - KinescopePlayer

    public required convenience init(config: KinescopePlayerConfig) {
        self.init(config: config, dependencies: KinescopeVideoPlayerDependencies())
    }

    public func play() {
        if let video {
            if !strategy.player.isReadyToPlay {
                select(quality: .auto(hlsLink: video.hlsLink))
            }
            self.strategy.play()
            self.delegate?.playerDidPlay()
        } else {
            self.load()
        }
    }

    public func pause() {
        self.strategy.pause()
        self.delegate?.playerDidPause()
    }

    public func stop() {
        self.strategy.pause()
        self.strategy.unbind()
        self.delegate?.playerDidStop()
    }

    public func attach(view: KinescopePlayerView) {
        view.playerView.player = self.strategy.player
        view.delegate = self
        self.view = view
        view.set(preview: video?.poster?.url)
        view.set(options: options)
        view.pipController?.delegate = pipDelegate
        updateTimeline()
        updateLiveIndicator()
        observePlaybackTime()
        addPlayerTimeControlStatusObserver()
        addPlayerStatusObserver()
    }

    public func detach(view: KinescopePlayerView) {
        view.playerView.player = nil
        self.view = nil
        view.delegate = nil

        removePlaybackTimeObserver()
        kvoBag.removeObserver(for: .playerTimeControlStatus)
        kvoBag.removeObserver(for: .playerStatus)
    }

    public func select(quality: KinescopeVideoQuality) {

        savedTime = strategy.player.currentTime()

        kvoBag.removeObserver(for: .playerItemStatus)

        if let item = quality.makeItem(with: drmHandler) {
            strategy.bind(item: item)
        }

        // changing quality
        strategy.player.currentItem?.preferredPeakBitRate = quality.preferredMaxBitRate

        addPlayerItemStatusObserver()
    }

    public func setDelegate(delegate: KinescopeVideoPlayerDelegate) {
        self.delegate = delegate
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
                self?.view?.set(preview: video.poster?.url)
                self?.view?.overlay?.set(title: video.title, subtitle: video.description)
                self?.view?.set(options: self?.makePlayerOptions(from: video) ?? [])
                self?.delegate?.playerDidLoadVideo(error: nil)
                self?.play()
            },
            onError: { [weak self] error in
                self?.view?.stopLoader()
                self?.delegate?.playerDidLoadVideo(error: error)
                Kinescope.shared.logger?.log(error: error, level: KinescopeLoggerLevel.network)
            }
        )
    }

    func makePlayerOptions(from video: KinescopeVideo) -> [KinescopePlayerOption] {
        var options: [KinescopePlayerOption] = [.airPlay, .settings, .fullscreen, .more]

        if FeatureToggle.assetDownloaderEnabled && video.hasAssets {
            options.insert(.download, at: 1)
        }

        if video.hasAttachments {
            options.insert(.attachments, at: 0)
        }

        if AVPictureInPictureController.isPictureInPictureSupported() {
            options.insert(.pip, at: options.count - 2)
        }

        if video.hasSubtitles {
            options.insert(.subtitles, at: 0)
        }

        self.options = options
        return options
    }

    func observePlaybackTime() {
        guard view?.controlPanel != nil else {
            return
        }

        playbackObserverFactory = PlaybackTimePeriodicObserver(period: CMTimeMakeWithSeconds(0.01,
                                                                                      preferredTimescale: CMTimeScale(NSEC_PER_SEC)),
                                                        playerBody: self,
                                                        secondsPlayed: { [weak self] updatedTime in
            guard let self, !isSeeking, !isPreparingSeek else {
                return
            }
            
            time = updatedTime
        })
        playbackObserver = playbackObserverFactory?.provide()
    }

    func removePlaybackTimeObserver() {
        if let timeObserver = playbackObserver {
            strategy.player.removeTimeObserver(timeObserver)
            self.playbackObserver = nil
        }
    }

    func addPlayerStatusObserver() {
        let observerFactory = PlayerStatusObserver(playerBody: self, 
                                                   repeater: $playRepeater)
        kvoBag.addObserver(for: .playerStatus, using: .init(wrappedFactory: observerFactory))
    }

    func addPlayerItemStatusObserver() {
        let observerFactory = CurrentItemStatusObserver(playerBody: self, 
                                                        repeater: $playRepeater,
                                                        readyToPlayReceived: { [weak self] in
            guard let self else {
                return
            }
            let seconds = savedTime.seconds
            if seconds > .zero {
                time = seconds
                savedTime = .zero
                seek(to: seconds)
            }
        })
        kvoBag.addObserver(for: .playerItemStatus, using: .init(wrappedFactory: observerFactory))
    }

    func addPlayerTimeControlStatusObserver() {
        let observerFactory = TimeControlStatusObserver(playerBody: self,
                                                        timeControlStatusChanged: { [weak self] status in
            self?.isPlaying = status == .playing
        })
        kvoBag.addObserver(for: .playerTimeControlStatus, using: .init(wrappedFactory: observerFactory))
    }

    func addNotofications() {
        notificationsBag.addObserver(for: .appWillEnterForeground,
                                     using: .init(selector: #selector(appWillEnterForeground)))
        notificationsBag.addObserver(for: .appDidEnterBackground,
                                     using: .init(selector: #selector(appDidEnterBackground)))
        notificationsBag.addObserver(for: .deviceOrientationChanged,
                                     using: .init(selector: #selector(changeOrientation)))
    }

    func seek(to seconds: TimeInterval) {
        let duration = strategy.player.durationSeconds ?? .zero
        // end of timeline reached
        if seconds >= duration {
            if strategy.player.hasFiniteDuration {
                // stop playing vod
                pause()
            } else {
                // continue live stream
                isLive = true
            }
        } else {
            // seek backward, so it is not live anymore
            isLive = false
        }
        self.isSeeking = true
        let time = CMTime(seconds: seconds, preferredTimescale: CMTimeScale(NSEC_PER_SEC))

        Kinescope.shared.logger?.log(message: "timeline changed to \(seconds) seconds",
                                     level: KinescopeLoggerLevel.player)
        delegate?.player(didSeekTo: seconds)

        strategy.player.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero) { [weak self] _ in
            self?.isSeeking = false
        }
    }

    @objc
    func changeOrientation() {
        guard let view = view,
              view.canBeFullScreen else {
            return
        }

        let isFullScreen = UIApplication.shared.keyWindow?.rootViewController?.presentedViewController is KinescopeFullscreenViewController

        if UIDevice.current.orientation.isLandscape && !isFullScreen {
            didPresentFullscreen(from: view)
        } else if !UIDevice.current.orientation.isLandscape && isFullScreen {
            didPresentFullscreen(from: view)
        }
    }

    @objc func appWillEnterForeground() {
        if !(view?.pipController?.isPictureInPictureActive ?? false) {
            view?.playerView.player = strategy.player
        }
    }

    @objc func appDidEnterBackground() {
        if !(view?.pipController?.isPictureInPictureActive ?? false) {
            view?.playerView.player = nil
        }
    }

    func restoreView() {
        view?.showOverlay(isOverlayed)
        isPlaying ? play() : pause()
    }

    func updateTimeline() {
        let duration = strategy.player.durationSeconds ?? .zero

        let position = CGFloat(time / duration)
        if !position.isNaN {
            view?.controlPanel?.setTimeline(to: CGFloat(position))
        }
        if !time.isNaN {
            view?.controlPanel?.setIndicator(to: time)
        }
    }

    func updateLiveIndicator() {
        switch video?.type {
        case .live:
            view?.controlPanel?.set(live: isLive)
        case .none, .vod:
            view?.controlPanel?.set(live: nil)
        }
    }

}

// MARK: - KinescopePlayerViewDelegate

extension KinescopeVideoPlayer: KinescopePlayerViewDelegate {

    func didPlay() {
        let duration = strategy.player.durationSeconds ?? .zero
        // Playing from start should not be available for live streams
        if time == duration && strategy.player.hasFiniteDuration {
            time = .zero
            seek(to: time)
        }
        
        self.$playRepeater.reset()
        self.play()
    }

    func didPause() {
        self.pause()
    }

    func didSeek(to position: Double) {
        isPreparingSeek = true

        guard let duration = strategy.player.durationSeconds else {
            return
        }

        Kinescope.shared.logger?.log(message: "timeline seeked to \(position)",
                                     level: KinescopeLoggerLevel.player)

        time = min(duration, position * duration)

        delegate?.player(timelinePositionMovedTo: position)
    }

    func didConfirmSeek() {
        isPreparingSeek = false
        Kinescope.shared.logger?.log(message: "timeline change to time: \(time) confirmed",
                                     level: KinescopeLoggerLevel.player)
        seek(to: time)
    }

    func didFastForward() {
        guard let duration = strategy.player.durationSeconds else {
            return
        }

        Kinescope.shared.logger?.log(message: "fast forward +15s", level: KinescopeLoggerLevel.player)

        time = min(duration, time + 15)
        seek(to: time)

        delegate?.player(didFastForwardTo: time)
    }

    func didFastBackward() {
        Kinescope.shared.logger?.log(message: "fast backward -15s", level: KinescopeLoggerLevel.player)

        time = max(time - 15.0, .zero)
        seek(to: time)

        delegate?.player(didFastBackwardTo: time)
    }

    func didPresentFullscreen(from view: KinescopePlayerView) {
        if KinescopeFullscreenViewController.isPresented {
            isOverlayed = view.overlay?.isSelected ?? false
            detach(view: view)
            
            KinescopeFullscreenViewController.dismiss { [weak self] in
                guard
                    let self,
                    let miniView = self.miniView
                else {
                    return
                }

                self.attach(view: miniView)
                self.view?.change(quality: self.currentQuality)
                self.restoreView()
            }
        } else {
            miniView = view
            isOverlayed = view.overlay?.isSelected ?? false

            detach(view: view)
            
            guard let video else {
                return
            }

            KinescopeFullscreenViewController.present(player: self,
                                                      video: video) { [weak self] in
                guard let video = self?.video else {
                    return
                }

                self?.view?.overlay?.isHidden = false
                self?.view?.change(quality: self?.currentQuality ?? "")
                self?.view?.overlay?.set(title: video.title, subtitle: video.description)
                self?.restoreView()
            }
        }
    }

    func didShowAttachments() -> [KinescopeVideoAdditionalMaterial]? {
        return video?.attachments
    }

    func didShowAssets() -> [KinescopeVideoAsset]? {
        return video?.downloadableAssets
    }

    func didSelect(quality: String) {
        guard let video = video else {
            Kinescope.shared.logger?.log(message: "Can't find video",
                                         level: KinescopeLoggerLevel.player)
            return
        }

        let videoQuality: KinescopeVideoQuality
        if let asset = video.firstQuality(by: quality) {
            if let path = dependencies.assetDownloader.getLocation(by: video.id + asset.name) {
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

        delegate?.player(changedQualityTo: quality)
    }

    func didSelectAttachment(with id: String) {
        guard let attachment = video?.firstAttachment(by: id) else {
            return
        }
        dependencies.attachmentDownloader.enqueueDownload(attachment: attachment)
        Kinescope.shared.logger?.log(message: "Start downloading attachment: \(attachment.title)",
                                     level: KinescopeLoggerLevel.player)
    }

    func didSelectDownloadAll(for title: String) {
        guard let video else {
            return
        }

        switch SideMenu.DescriptionTitle.getType(by: title) {
        case .attachments:
            video.attachments?.forEach {
                dependencies.attachmentDownloader.enqueueDownload(attachment: $0)
                Kinescope.shared.logger?.log(message: "Start downloading attachment: \($0.title)",
                                             level: KinescopeLoggerLevel.player)
            }
        case .download:
            video.downloadableAssets.forEach {
                dependencies.assetDownloader.enqueueDownload(video: video, asset: $0)
                Kinescope.shared.logger?.log(message: "Start downloading asset: \($0.name) - \(video.id)",
                                             level: KinescopeLoggerLevel.player)
            }
        case .none:
            break
        }
    }

    func didShowSubtitles() -> [String] {
        return video?.allSubtitlesVariants ?? []
    }

    func didSelect(subtitles: String) {
        guard let video = video else {
            Kinescope.shared.logger?.log(message: "Can't find video",
                                         level: KinescopeLoggerLevel.player)
            return
        }

        guard let item = self.strategy.player.currentItem,
                let group = item.asset.mediaSelectionGroup(forMediaCharacteristic: .legible) else {
            return
        }

        if let selectedSubtitles = video.firstSubtitle(by: subtitles) {
            let locale = Locale(identifier: selectedSubtitles.language)
            let options = AVMediaSelectionGroup.mediaSelectionOptions(from: group.options,
                                                                      with: locale)
            self.strategy.player.currentItem?.select(options.first, in: group)
        } else {
            self.strategy.player.currentItem?.select(nil, in: group)
        }

        self.strategy.player.currentItem?.textStyleRules = textStyleRules

        let isOn = video.hasSubtitle(with: subtitles)
        view?.controlPanel?.set(subtitleOn: isOn)
        Kinescope.shared.logger?.log(message: "Select subtitles: \(subtitles)",
                                     level: KinescopeLoggerLevel.player)
    }

}
