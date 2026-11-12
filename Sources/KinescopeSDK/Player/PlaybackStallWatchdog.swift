import Foundation

/// Pauses playback which is stuck in buffering: position hasn't moved for a long time.
final class PlaybackStallWatchdog {

    private enum Constants {
        static let pollInterval: TimeInterval = 1
        static let stallTimeout: TimeInterval = 15
        static let minProgress: TimeInterval = 0.5
    }

    // MARK: - Private Properties

    private let currentTime: () -> TimeInterval
    private let onStall: () -> Void

    private var timer: Timer?
    private var lastPosition: TimeInterval = 0
    private var stalledFor: TimeInterval = 0

    // MARK: - Lifecycle

    init(currentTime: @escaping () -> TimeInterval,
         onStall: @escaping () -> Void) {
        self.currentTime = currentTime
        self.onStall = onStall
    }

    deinit {
        timer?.invalidate()
    }

    // MARK: - Methods

    func bufferingStarted() {
        guard timer == nil else {
            return
        }
        lastPosition = currentTime()
        stalledFor = 0
        timer = Timer.scheduledTimer(withTimeInterval: Constants.pollInterval, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }

    func reset() {
        timer?.invalidate()
        timer = nil
        stalledFor = 0
    }

}

// MARK: - Private

private extension PlaybackStallWatchdog {

    func tick() {
        let position = currentTime()
        if abs(position - lastPosition) >= Constants.minProgress {
            lastPosition = position
            stalledFor = 0
            return
        }

        stalledFor += Constants.pollInterval
        guard stalledFor >= Constants.stallTimeout else {
            return
        }

        reset()
        onStall()
    }

}
