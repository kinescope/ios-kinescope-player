protocol PlayerOverlayViewDelegate: class {
    func didTap(isSelected: Bool)
    func didPlayPause()
    func didFastForward(sec: Double)
    func didFastBackward(sec: Double)
}
