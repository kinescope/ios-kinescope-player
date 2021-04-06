protocol KinescopePlayerViewDelegate: class {
    func didPlay(videoEnded: Bool)
    func didPause()
    func didSeek(to position: Double)
    func didFastForward()
    func didFastBackward()
    func didPresentFullscreen(from view: KinescopePlayerView)
    func didShowQuality() -> [String]
    func didSelect(quality: String)
}
