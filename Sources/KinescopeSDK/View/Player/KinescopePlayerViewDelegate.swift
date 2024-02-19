protocol KinescopePlayerViewDelegate: class {
    func didPlay()
    func didPause()
    func didSeek(to position: Double)
    func didConfirmSeek()
    func didFastForward()
    func didFastBackward()
    func didPresentFullscreen(from view: KinescopePlayerView)
    func didShowAttachments() -> [KinescopeVideoAdditionalMaterial]?
    func didShowAssets() -> [KinescopeVideoAsset]?
    func didSelect(quality: String)
    func didSelectAttachment(with index: Int)
    func didSelectAsset(with index: Int)
    func didSelectDownloadAll(for title: String)
    func didShowSubtitles() -> [String]
    func didSelect(subtitles: String)
}
