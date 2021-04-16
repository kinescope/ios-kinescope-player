//
//  KinescopeAttachmentDownloadableDelegateMock.swift
//  KinescopeSDKTests
//
//  Created by Никита Гагаринов on 11.04.2021.
//

import Foundation
@testable import KinescopeSDK

//swiftlint:disable all
final class KinescopeAttachmentDownloadableDelegateMock: KinescopeAttachmentDownloadableDelegate {

    var attachments: [String: (url: URL?, progress: Double, error: KinescopeDownloadError?)] = [:]

    func attachmentDownloadProgress(attachmentId: String, progress: Double) {
        attachments[attachmentId] = (nil, progress, nil)
    }

    func attachmentDownloadError(attachmentId: String, error: KinescopeDownloadError) {
        attachments[attachmentId] = (nil, 0, error)
    }

    func attachmentDownloadComplete(attachmentId: String, url: URL?) {
        attachments[attachmentId] = (url, 1, nil)
    }

}
