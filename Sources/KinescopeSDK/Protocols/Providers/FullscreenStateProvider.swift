//
//  FullscreenStateProvider.swift
//  KinescopeSDK
//
//  Created by Nikita Korobeinikov on 12.03.2024.
//

import Foundation

protocol FullscreenStateProvider: AnyObject {
    var isFullScreenModeActive: Bool { get }
}
