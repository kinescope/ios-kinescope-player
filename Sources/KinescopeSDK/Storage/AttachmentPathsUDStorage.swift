//
//  AttachmentPathsUDStorage.swift
//  KinescopeSDK
//
//  Created by Artemii Shabanov on 06.04.2021.
//

import Foundation

final class AttachmentPathsUDStorage: KinescopeAttachmentPathsStorage {

    // MARK: - Properties

    private let udStroage = PathsUDStorage(suffix: "attachments")

    // MARK: - KinescopeAttachmentPathsStorage

    func saveAttachment(relativeUrl: String, id attachmentId: String) {
        udStroage.save(relativeUrl: relativeUrl, id: attachmentId)
    }

    func readAttachmentUrl(by attachmentId: String) -> URL? {
        return constructUrl(relativeUrl: udStroage.readUrl(by: attachmentId))
    }

    func fetchAttachmentIds() -> [String] {
        return udStroage.fetchIds()
    }

    func deleteAttachmentUrl(by attachmentId: String) -> URL? {
        return constructUrl(relativeUrl: udStroage.deleteUrl(by: attachmentId))
    }

    // MARK: - Private

    private func constructUrl(relativeUrl: String?) -> URL? {
        guard let relativeUrl = relativeUrl else { return nil}
        let baseURL = URL(fileURLWithPath: NSHomeDirectory())
        let assetURL = baseURL.appendingPathComponent(relativeUrl)
        return assetURL
    }

}
