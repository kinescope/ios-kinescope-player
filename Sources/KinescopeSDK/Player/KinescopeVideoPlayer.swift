import AVFoundation
import UIKit

public class KinescopeVideoPlayer: KinescopePlayer {

    // MARK: - Private Properties

    private let dependencies: KinescopePlayerDependencies
    private lazy var strategy: PlayingStrategy = {
        dependencies.provide(for: config)
    }()

    private weak var view: KinescopePlayerView?

    private var timeObserver: Any?
    private var statusObserver: NSKeyValueObservation?
    private var timeControlStatusObserver: NSKeyValueObservation?

    private var isSeeking = false
    private weak var miniView: KinescopePlayerView?

    private var video: KinescopeVideo?
    private let config: KinescopePlayerConfig
    private var options = [KinescopePlayerOption]()

    // MARK: - Lifecycle

    init(config: KinescopePlayerConfig, dependencies: KinescopePlayerDependencies) {
        self.dependencies = dependencies
        self.config = config
    }

    deinit {
        self.removePlaybackTimeObserver()
        self.removePlayerStatusObserver()
        self.removePlayerTimeControlStatusObserver()
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
    }

    public func attach(view: KinescopePlayerView) {

        view.playerView.player = self.strategy.player
        view.delegate = self

        self.view = view
        view.set(options: options)

        observePlaybackTime()
        addPlayerStatusObserver()
        addPlayerTimeControlStatusObserver()
    }

    public func detach(view: KinescopePlayerView) {
        view.playerView.player = nil
        self.view = nil
        view.delegate = nil

        removePlaybackTimeObserver()
        removePlayerStatusObserver()
        removePlayerTimeControlStatusObserver()
    }

    public func select(quality: KinescopeVideoQuality) {
        guard let item = quality.item else {
            // Log here critical error
            return
        }

        // Restore here sek position

        strategy.bind(item: item)
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
        var options: [KinescopePlayerOption] = [.settings, .fullscreen, .more]

        if !video.additionalMaterials.isEmpty {
            options.insert(.attachments, at: 0)
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

            /// Dose not make sense without control panel and curremtItem
            guard let controlPanel = self?.view?.controlPanel,
                  let currentItem = self?.strategy.player.currentItem else {
                return
            }

            // MARK: - Current time observation

            let time = time.seconds

            Kinescope.shared.logger?.log(message: "playback position changed to \(time) seconds", level: KinescopeLoggerLevel.player)

            controlPanel.setIndicator(to: time)

            let duration = currentItem.duration.seconds

            controlPanel.setTimeline(to: CGFloat(time / duration))

            // MARK: - Preload observation

            let buferredTime = currentItem.loadedTimeRanges.first?.timeRangeValue.end.seconds ?? 0

            Kinescope.shared.logger?.log(message: "playback buffered \(buferredTime) seconds", level: KinescopeLoggerLevel.player)

            controlPanel.setBufferred(progress: CGFloat(buferredTime / duration))
        }

    }

    func removePlaybackTimeObserver() {
        if let timeObserver = timeObserver {
            strategy.player.removeTimeObserver(timeObserver)
            self.timeObserver = nil
        }
    }

    func addPlayerStatusObserver() {
        self.statusObserver = self.strategy.player.observe(
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
        self.statusObserver?.invalidate()
        self.statusObserver = nil
    }

    func addPlayerTimeControlStatusObserver() {
        self.timeControlStatusObserver = self.strategy.player.observe(
            \.timeControlStatus,
            options: [.new, .old],
            changeHandler: { [weak self] item, _ in
                self?.view?.change(timeControlStatus: item.timeControlStatus)

                Kinescope.shared.logger?.log(
                    message: "AVPlayer.TimeControlStatus – \(item.timeControlStatus)",
                    level: KinescopeLoggerLevel.player
                )
            }
        )
    }

    func removePlayerTimeControlStatusObserver() {
        self.timeControlStatusObserver?.invalidate()
        self.timeControlStatusObserver = nil
    }

    func seek(to seconds: TimeInterval) {
        let time = CMTime(seconds: seconds, preferredTimescale: CMTimeScale(NSEC_PER_SEC))

        Kinescope.shared.logger?.log(message: "timeline changed to \(seconds) seconds",
                                     level: KinescopeLoggerLevel.player)

        isSeeking = true
        strategy.player.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero) { [weak self] _ in
            self?.isSeeking = false
        }
    }
}

// MARK: - PlayerOverlayViewDelegate

extension KinescopeVideoPlayer: KinescopePlayerViewDelegate {
    func didShowAttachments() -> [SideMenu.Item] {
        []
    }

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
            pause()
            detach(view: view)

            rootVC?.dismiss(animated: true, completion: { [weak self] in
                guard let miniView = self?.miniView else {
                    return
                }
                self?.attach(view: miniView)
                self?.play()
            })
        } else {
            miniView = view

            pause()
            detach(view: view)

            let playerVC = KinescopeFullscreenViewController(player: self,
                                                             config: .preferred(for: video))
            playerVC.modalPresentationStyle = .overFullScreen
            rootVC?.present(playerVC, animated: true, completion: { [weak self] in
                self?.play()
                self?.view?.change(status: .readyToPlay)
            })
        }
    }

    func didShowQuality() -> [String] {
        return video?.assets
            .compactMap { $0.quality }
            .filter { $0 != "original" } ?? []
    }

    func didSelect(quality: String) {
        // FIXME: Add logic
        Kinescope.shared.logger?.log(message: "Select quality: \(quality)",
                                     level: KinescopeLoggerLevel.player)
    }
}
