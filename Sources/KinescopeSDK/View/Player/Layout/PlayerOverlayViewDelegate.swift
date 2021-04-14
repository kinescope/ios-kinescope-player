protocol PlayerOverlayViewDelegate: class {
    func didShow()
    func didHide()
    func didPlay(videoEnded: Bool)
    func didPause()
    func didFastForward()
    func didFastBackward()
}
