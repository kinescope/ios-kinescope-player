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

enum DataProtectionHandlers {

    static func make(for video: KinescopeVideo, persistable: Bool) -> DataProtectionHandler? {
        guard video.drm != nil else {
            return nil
        }
        let service = DataProtectionNetworkService(transport: Transport())
        if #available(iOS 11, *) {
            return DataProtectionKeySessionHandler(video: video, service: service, persistable: persistable)
        }
        return DataProtectionResourceDelegateHandler(video: video, service: service)
    }

}

struct DefaultDataProtectionHandlerFactory: DataProtectionHandlerFactory {
    
    let service: DataProtectionService

    func provide(for video: KinescopeVideo) -> DataProtectionHandler? {
        guard video.drm != nil else {
            return nil
        }
        if #available(iOS 11, *) {
            return DataProtectionKeySessionHandler(video: video, service: service)
        } else {
            return DataProtectionResourceDelegateHandler(video: video, service: service)
        }
    }

}
