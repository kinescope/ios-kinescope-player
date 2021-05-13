import UIKit

protocol PlayerOverlayViewDelegate: AnyObject {
    func didTap(isSelected: Bool)
    func didPlayPause()
    func didAlphaChanged(alpha: CGFloat)
    func didFastForward(sec: Double)
    func didFastBackward(sec: Double)
}
