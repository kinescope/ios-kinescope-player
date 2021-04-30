protocol KinescopePlayerViewDelegate: class {
    func didPlayPause()
    func didSeek(to position: Double)
    func didConfirmSeek()
    func didFastForward()
    func didFastBackward()
    func didPresentFullscreen(from view: KinescopePlayerView)
    func didShowQuality() -> [String]
    func didShowAttachments() -> [KinescopeVideoAdditionalMaterial]?
    func didShowAssets() -> [KinescopeVideoAsset]?
    func didSelect(quality: String)
    func didSelectAttachment(with index: Int)
    func didSelectAsset(with index: Int)
    func didSelectDownloadAll(for title: String)
    func didShowSubtitles() -> [String]
    func didSelect(subtitles: String)
    func didRefresh()
}
