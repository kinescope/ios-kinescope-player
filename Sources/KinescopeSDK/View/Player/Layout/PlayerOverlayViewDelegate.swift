protocol PlayerOverlayViewDelegate: class {
    func didTap(isSelected: Bool)
    func didPlay(videoEnded: Bool)
    func didPause()
    func didFastForward()
    func didFastBackward()
}
