protocol KinescopePlayerViewDelegate: class {
    func didPlay(videoEnded: Bool)
    func didPause()
    func didSelect(option: KinescopePlayerOption)
}
