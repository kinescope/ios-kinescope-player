//
//  DataProtectionHandlerFactoryStub.swift
//
//
//  Created by Nikita Korobeinikov on 02.04.2024.
//

@testable import KinescopeSDK

struct DataProtectionHandlerFactoryStub: DataProtectionHandlerFactory {
    func provide(for video: KinescopeVideo) -> (any DataProtectionHandler)? {
        nil
    }
}
