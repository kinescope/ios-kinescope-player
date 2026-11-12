protocol PlayerOverlayViewDelegate: AnyObject {
    func didTap(isSelected: Bool)
    func didPlay()
    func didPause()
    func didFastForward()
    func didFastBackward()
    /// Finger went down on the video, before a seek or play tap is recognized.
    func didTouchVideo()
}
