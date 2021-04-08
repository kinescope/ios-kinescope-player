protocol KinescopePlayerViewDelegate: class {
    func didPlay(videoEnded: Bool)
    func didPause()
    func didSeek(to position: Double)
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
}
