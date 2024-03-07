//
//  KinescopeVideo+Attachments.swift
//  KinescopeSDK
//
//  Created by Nikita Korobeinikov on 20.02.2024.
//

import Foundation

extension KinescopeVideo {

    var hasAttachments: Bool {
        !(attachments?.isEmpty ?? true)
    }
    
    func firstAttachment(by id: String) -> KinescopeVideoAdditionalMaterial? {
        attachments?.first(where: { $0.id == id })
    }

}
