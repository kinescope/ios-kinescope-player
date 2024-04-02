//
//  AssetLinksServiceMock.swift
//  KinescopeSDKTests
//
//  Created by Artemii Shabanov on 07.04.2021.
//

@testable import KinescopeSDK

final class AssetLinksServiceMock: AssetLinksService {

    // MARK: - Properties

    var linkMock: [String: KinescopeVideoAssetLink] = [:]

    // MARK: - Methods

    func getAssetLink(by id: String, asset: KinescopeSDK.KinescopeVideoAsset) -> KinescopeSDK.KinescopeVideoAssetLink {
        if let result = linkMock[id] {
            return result
        } else {
            fatalError("Cannot find mock for getAssetLink by \(id)")
        }
    }

}
