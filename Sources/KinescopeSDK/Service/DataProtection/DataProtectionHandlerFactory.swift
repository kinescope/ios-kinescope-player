//
//  DataProtectionHandlerFactory.swift
//  KinescopeSDK
//
//  Created by Nikita Korobeinikov on 21.02.2024.
//

import Foundation

public protocol DataProtectionHandlerFactory {
    func provide(for videoId: String) -> DataProtectionHandler?
}

struct DefaultDataProtectionHandlerFactory: DataProtectionHandlerFactory {
    
    let service: DataProtectionService

    func provide(for videoId: String) -> DataProtectionHandler? {
//        return DataProtectionKeySessionHandler(videoId: videoId, service: service)
        return DataProtectionResourceDelegateHandler(videoId: videoId, service: service)
    }

}
