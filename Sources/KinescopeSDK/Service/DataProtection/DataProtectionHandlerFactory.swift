//
//  DataProtectionHandlerFactory.swift
//  KinescopeSDK
//
//  Created by Nikita Korobeinikov on 21.02.2024.
//

import Foundation

public protocol DataProtectionHandlerFactory {
    func provide(for video: KinescopeVideo) -> DataProtectionHandler?
}

struct DefaultDataProtectionHandlerFactory: DataProtectionHandlerFactory {
    
    let service: DataProtectionService

    func provide(for video: KinescopeVideo) -> DataProtectionHandler? {
        if #available(iOS 11, *) {
            return DataProtectionKeySessionHandler(video: video, service: service)
        } else {
            return DataProtectionResourceDelegateHandler(video: video, service: service)
        }
    }

}
