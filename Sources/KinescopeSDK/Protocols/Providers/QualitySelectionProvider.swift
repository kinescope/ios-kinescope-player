//
//  QualitySelectionProvider.swift
//  KinescopeSDK
//
//  Created by Nikita Korobeinikov on 12.03.2024.
//

import Foundation

protocol QualitySelectionProvider: AnyObject {
    var currentQuality: String { get }
}
