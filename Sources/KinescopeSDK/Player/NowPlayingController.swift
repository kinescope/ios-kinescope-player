import MediaPlayer
import UIKit

/// Publishes playback info to Lock Screen / Control Center and handles remote commands.
final class NowPlayingController {

    struct Info {
        let title: String?
        let subtitle: String?
        let duration: TimeInterval?
        let elapsed: TimeInterval
        let rate: Float
        let isLive: Bool
    }

    struct Handlers {
        let play: () -> Void
        let pause: () -> Void
        let seekTo: (TimeInterval) -> Void
        let seekBy: (TimeInterval) -> Void
    }

    // MARK: - Private Properties

    private let handlers: Handlers
    private var commandTargets: [(command: MPRemoteCommand, target: Any)] = []
    private var artwork: MPMediaItemArtwork?
    private var artworkURL: String?
    private var lastInfo: Info?

    private var commandCenter: MPRemoteCommandCenter {
        .shared()
    }

    // MARK: - Lifecycle

    init(handlers: Handlers) {
        self.handlers = handlers
    }

    deinit {
        deactivate()
    }

    // MARK: - Methods

    func activate() {
        guard commandTargets.isEmpty else {
            return
        }

        addTarget(commandCenter.playCommand) { [handlers] _ in
            handlers.play()
            return .success
        }
        addTarget(commandCenter.pauseCommand) { [handlers] _ in
            handlers.pause()
            return .success
        }
        addTarget(commandCenter.togglePlayPauseCommand) { [weak self] _ in
            guard let self else {
                return .commandFailed
            }
            (lastInfo?.rate ?? 0) > 0 ? handlers.pause() : handlers.play()
            return .success
        }

        commandCenter.skipForwardCommand.preferredIntervals = [NSNumber(value: FastSeek.step)]
        addTarget(commandCenter.skipForwardCommand) { [handlers] _ in
            handlers.seekBy(FastSeek.step)
            return .success
        }
        commandCenter.skipBackwardCommand.preferredIntervals = [NSNumber(value: FastSeek.step)]
        addTarget(commandCenter.skipBackwardCommand) { [handlers] _ in
            handlers.seekBy(-FastSeek.step)
            return .success
        }
        addTarget(commandCenter.changePlaybackPositionCommand) { [handlers] event in
            guard let event = event as? MPChangePlaybackPositionCommandEvent else {
                return .commandFailed
            }
            handlers.seekTo(event.positionTime)
            return .success
        }
    }

    func deactivate() {
        commandTargets.forEach { $0.command.removeTarget($0.target) }
        commandTargets.removeAll()
        lastInfo = nil
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
    }

    func update(_ info: Info) {
        guard !commandTargets.isEmpty else {
            return
        }
        lastInfo = info

        let isSeekable = !info.isLive && info.duration != nil
        commandCenter.skipForwardCommand.isEnabled = isSeekable
        commandCenter.skipBackwardCommand.isEnabled = isSeekable
        commandCenter.changePlaybackPositionCommand.isEnabled = isSeekable

        var nowPlayingInfo: [String: Any] = [
            MPNowPlayingInfoPropertyElapsedPlaybackTime: info.elapsed,
            MPNowPlayingInfoPropertyPlaybackRate: info.rate,
            MPNowPlayingInfoPropertyDefaultPlaybackRate: 1.0,
            MPNowPlayingInfoPropertyIsLiveStream: info.isLive,
            MPNowPlayingInfoPropertyMediaType: MPNowPlayingInfoMediaType.video.rawValue
        ]
        if let title = info.title {
            nowPlayingInfo[MPMediaItemPropertyTitle] = title
        }
        if let subtitle = info.subtitle, !subtitle.isEmpty {
            nowPlayingInfo[MPMediaItemPropertyArtist] = subtitle
        }
        if let duration = info.duration, !info.isLive {
            nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = duration
        }
        if let artwork {
            nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
        }
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }

    func loadArtwork(from urlString: String?) {
        guard urlString != artworkURL else {
            return
        }
        artworkURL = urlString
        artwork = nil

        guard let urlString, let url = URL(string: urlString) else {
            return
        }

        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let data, let image = UIImage(data: data) else {
                return
            }
            DispatchQueue.main.async {
                guard let self, self.artworkURL == urlString else {
                    return
                }
                self.artwork = MPMediaItemArtwork(boundsSize: image.size) { _ in image }
                if let info = self.lastInfo {
                    self.update(info)
                }
            }
        }.resume()
    }

}

// MARK: - Private

private extension NowPlayingController {

    func addTarget(_ command: MPRemoteCommand,
                   handler: @escaping (MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus) {
        command.isEnabled = true
        let target = command.addTarget(handler: handler)
        commandTargets.append((command, target))
    }

}
