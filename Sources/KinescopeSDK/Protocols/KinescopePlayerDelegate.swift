
/// Recieve updates from KinescopePlayer
public protocol KinescopePlayerDelegate: class {

    /// Called when the asset  was download
    func kinescopePlayerDidReadyToPlay(player: KinescopePlayer)
    /// Called when the asset  was not download
    func kinescopePlayerDataLoadingFailed(player: KinescopePlayer, error: Error)
}
