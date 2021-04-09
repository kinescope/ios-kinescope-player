//
//  KinescopeAttachmentsPathsStorage.swift
//  KinescopeSDK
//
//  Created by Artemii Shabanov on 06.04.2021.
//

import Foundation

/// It should provide consistency of saved and read urls
protocol KinescopeAttachmentPathsStorage {
    func saveAttachment(relativeUrl: String, id attachmentId: String)
    /// Returns full url
    func readAttachmentUrl(by attachmentId: String) -> URL?
    func fetchAttachmentIds() -> [String]
    /// Returns full url
    func deleteAttachmentUrl(by attachmentId: String) -> URL?
}
