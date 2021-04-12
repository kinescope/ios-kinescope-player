//
//  FileServiceMock.swift
//  KinescopeSDKTests
//
//  Created by Никита Гагаринов on 11.04.2021.
//

import Foundation
@testable import KinescopeSDK

final class FileServiceMock: FileService {

    // MARK: - Nested Types

    enum AttachmenState {
        case completed
        case progress(Double)
        case error(KinescopeDownloadError)
    }

    // MARK: - Properties
    
    weak var delegate: FileServiceDelegate?
    var attachmentStates: [String: AttachmenState] = [:]

    // MARK: - FileService

    func enqueueDownload(fileId: String, url: URL) {
        switch attachmentStates[fileId] {
        case .completed:
            let directory = FileManager.default.temporaryDirectory
            let fileUrl = directory.appendingPathComponent(fileId)
            try? "mockData".write(to: fileUrl, atomically: true, encoding: .utf8)
            delegate?.downloadComplete(fileId: fileId, path: fileUrl)
        case .none:
            fatalError("Cannot find mock for enqueueDownload by assetId)")
        case .progress(let value):
            delegate?.downloadProgress(fileId: fileId, progress: value)
        case .error(let error):
            delegate?.downloadError(fileId: fileId, error: error)
        }
    }

    func pauseDownload(fileId: String) {
    }

    func resumeDownload(fileId: String) {
    }

    func dequeueDownload(fileId: String) {
    }

    func restore() {
    }

}
