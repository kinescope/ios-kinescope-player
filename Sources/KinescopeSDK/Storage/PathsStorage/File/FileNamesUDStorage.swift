//
//  FileNamesUDStorage.swift
//  KinescopeSDK
//
//  Created by Artemii Shabanov on 06.04.2021.
//

import Foundation

/// KinescopeFileNamesStorage implementation based on PathsUDStorage
final class FileNamesUDStorage: KinescopeFileNamesStorage {

    // MARK: - Properties

    private let udStroage: PathsUDStorage

    // MARK: - Init

    init(suffix: String) {
        udStroage = PathsUDStorage(suffix: suffix)
    }

    // MARK: - KinescopeAttachmentPathsStorage

    func saveFile(name: String, id fileId: String) {
        udStroage.save(relativeUrl: name, id: fileId)
    }

    func readFileName(by fileId: String) -> String? {
        return udStroage.readUrl(by: fileId)
    }

    func fetchFileNames() -> [String] {
        return udStroage.fetchIds()
    }
    @discardableResult
    func deleteFileName(by fileId: String) -> String? {
        return udStroage.deleteUrl(by: fileId)
    }

}
