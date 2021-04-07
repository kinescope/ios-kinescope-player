//
//  AssetsServiceMock.swift
//  KinescopeSDKTests
//
//  Created by Artemii Shabanov on 07.04.2021.
//

@testable import KinescopeSDK

final class AssetLinksServiceMock: AssetLinksService {

    // MARK: - Properties

    var linkMock: [String: Result<KinescopeVideoAssetLink, Error>] = [:]

    // MARK: - Methods

    func getAssetLink(by id: String, completion: @escaping (Result<KinescopeVideoAssetLink, Error>) -> Void) {
        if let result = linkMock[id] {
            completion(result)
        } else {
            fatalError("Cannot find mock for getAssetLink by \(id)")
        }
    }

}
