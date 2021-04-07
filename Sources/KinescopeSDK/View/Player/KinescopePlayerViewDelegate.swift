protocol KinescopePlayerViewDelegate: class {
    func didPlay(videoEnded: Bool)
    func didPause()
    func didSeek(to position: Double)
    func didFastForward()
    func didFastBackward()
    func didPresentFullscreen(from view: KinescopePlayerView)
    func didShowQuality() -> [String]
    func didShowAttachments() -> [SideMenu.Item]
    func didSelect(quality: String)
    func didSelectAttachment(id: String)
    func didSelectDownloadAll(for title: String)
}
