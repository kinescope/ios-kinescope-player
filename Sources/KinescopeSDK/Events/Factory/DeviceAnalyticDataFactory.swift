//
//  DeviceAnalyticDataFactory.swift
//  KinescopeSDK
//
//  Created by Nikita Korobeinikov on 12.03.2024.
//

import UIKit

final class DeviceAnalyticDataFactory: Factory {
    typealias T = Analytics_Device
    
    // MARK: - Properties

    private let device = UIDevice.current
    private let screenBounds = UIScreen.main.nativeBounds
    
    // MARK: - Methods

    func provide() -> T? {
        var result = T()
        result.os = device.systemName
        result.osversion = device.systemVersion
        result.screenWidth = UInt32(screenBounds.width)
        result.screenHeight = UInt32(screenBounds.height)
        return result
    }
}
