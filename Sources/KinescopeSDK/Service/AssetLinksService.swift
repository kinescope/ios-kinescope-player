import Foundation

public protocol AssetLinksService {
    func getAssetLink(by id: String, asset: KinescopeVideoAsset) -> KinescopeVideoAssetLink
}

final class AssetLinksLocalService: AssetLinksService {

    // MARK: - Private Properties

    private let config: KinescopeConfig

    // MARK: - Lifecycle

    init(config: KinescopeConfig) {
        self.config = config
    }

    // MARK: - Public Methods
    
    func getAssetLink(by id: String, asset: KinescopeVideoAsset) -> KinescopeVideoAssetLink {
        // Legacy per-asset download (off behind `FeatureToggle.assetDownloaderEnabled`): a guessed `.mp4` link.
        KinescopeVideoAssetLink(link: "\(config.endpoint)\(id)/\(asset.name).mp4")
    }

}
