protocol KinescopePlayerViewDelegate: class {
    func didPlay(videoEnded: Bool)
    func didPause()
    func didSeek(to position: Double)
    func presentFullscreen(from view: KinescopePlayerView)
}
