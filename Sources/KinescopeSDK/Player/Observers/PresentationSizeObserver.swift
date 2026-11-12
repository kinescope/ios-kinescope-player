import Foundation
import AVFoundation

final class PresentationSizeObserver: KVOObserverFactory {

    private weak var playerBody: KinescopePlayerBody?

    private var presentationSizeChanged: (_ old: CGSize, _ new: CGSize) -> Void

    init(playerBody: KinescopePlayerBody,
         presentationSizeChanged: @escaping (_ old: CGSize, _ new: CGSize) -> Void) {
        self.playerBody = playerBody
        self.presentationSizeChanged = presentationSizeChanged
    }

    func provide() -> NSKeyValueObservation? {
        playerBody?.strategy.player.currentItem?.observe(
            \.presentationSize,
            options: [.initial, .new, .old],
            changeHandler: { [weak self] item, value in
                let old = value.oldValue ?? .zero
                let new = value.newValue ?? item.presentationSize
                // Keep the first real size even when old and new match. Auto often
                // reaches HD before this observer exists, and that event was dropped.
                guard new.width > 1, new.height > 1 else {
                    return
                }
                if value.oldValue != nil, old == new {
                    return
                }
                DispatchQueue.main.async {
                    Kinescope.shared.logger?.log(message: "AVPlayerItem.presentationSize – \(new)",
                                                 level: KinescopeLoggerLevel.player)
                    self?.presentationSizeChanged(old, new)
                    self?.playerBody?.delegate?.player(changedPresentationSizeTo: new)
                }
            }
        )
    }

}
