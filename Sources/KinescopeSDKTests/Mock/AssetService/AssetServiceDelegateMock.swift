//
//  AssetServiceDelegateMock.swift
//  KinescopeSDKTests
//
//  Created by Artemii Shabanov on 12.04.2021.
//

@testable import KinescopeSDK
import Foundation

final class AssetServiceDelegateMock: AssetServiceDelegate {

    var completionHandler: ((String, String?, KinescopeDownloadError?) -> Void)?

    func downloadProgress(assetId: String, progress: Double) {
        completionHandler?(assetId, nil, nil)
    }

    func downloadError(assetId: String, error: KinescopeDownloadError) {
        completionHandler?(assetId, nil, error)
    }

    func downloadComplete(assetId: String, path: String) {
        completionHandler?(assetId, path, nil)
    }

}
