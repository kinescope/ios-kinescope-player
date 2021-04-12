//
//  FileServiceDelegateMock.swift
//  KinescopeSDKTests
//
//  Created by Никита Гагаринов on 11.04.2021.
//

@testable import KinescopeSDK
import Foundation

final class FileServiceDelegateMock: FileServiceDelegate {

    var completionHandler: ((String, URL?, KinescopeDownloadError?) -> Void)?

    func downloadProgress(fileId: String, progress: Double) {
        completionHandler?(fileId, nil, nil)
    }

    func downloadError(fileId: String, error: KinescopeDownloadError) {
        completionHandler?(fileId, nil, error)
    }

    func downloadComplete(fileId: String, path: URL) {
        completionHandler?(fileId, path, nil)
    }

}
