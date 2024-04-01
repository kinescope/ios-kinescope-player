protocol KinescopePlayerViewDelegate: class {
    func didPlay()
    func didPause()
    func didSeek(to position: Double)
    func didConfirmSeek()
    func didFastForward()
    func didFastBackward()
    func didPresentFullscreen(from view: KinescopePlayerView)
    func didShowAttachments() -> [KinescopeVideoAdditionalMaterial]?
    func didSelect(rate: Float)
    func didSelect(quality: String)
    func didSelectAttachment(with id: String)
    func didSelectDownloadAll(for title: String)
    func didSelect(subtitles: String)
    func didSelect(option: AnyHashable)
}
