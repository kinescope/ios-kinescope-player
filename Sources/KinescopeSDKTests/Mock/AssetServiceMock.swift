//
//  AssetServiceMock.swift
//  KinescopeSDKTests
//
//  Created by Artemii Shabanov on 07.04.2021.
//

import Foundation
@testable import KinescopeSDK

final class AssetServiceMock: AssetService {

    // MARK: - Nested Types

    enum AssetState {
        case completed(String)
        case progress(Double)
        case error(KinescopeDownloadError)
    }

    // MARK: - Properties

    weak var delegate: AssetServiceDelegate?
    var assetStates: [String: AssetState] = [:]

    // MARK: - Methods

    func enqeueDownload(assetId: String) {
        switch assetStates[assetId] {
        case .completed(let value):
            let baseURL = URL(fileURLWithPath: NSHomeDirectory())
            let assetURL = baseURL.appendingPathComponent(value)
            do {
                try "mock string".write(to: assetURL, atomically: true, encoding: .utf8)
            } catch {
                print(error)
            }
            delegate?.downloadComplete(assetId: assetId, path: value)
        case .none:
            fatalError("Cannot find mock for enqeueDownload by assetId)")
        case .progress(let value):
            delegate?.downloadProgress(assetId: assetId, progress: value)
        case .error(let error):
            delegate?.downloadError(assetId: assetId, error: error)
        }
    }

    func pauseDownload(assetId: String) {
    }

    func resumeDownload(assetId: String) {
    }

    func deqeueDownload(assetId: String) {
    }

    func restore() {
    }

}
