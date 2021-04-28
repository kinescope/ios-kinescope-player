protocol PlayerOverlayViewDelegate: class {
    func didTap(isSelected: Bool)
    func didPlayPause()
    func didFastForward()
    func didFastBackward()
}
