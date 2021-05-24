//
//  KinescopeVideoDuration.swift
//  KinescopeSDK
//
//  Created by Никита Коробейников on 01.04.2021.
//

import Foundation

/// Video duration enum. Raw value - string in format: "mm:ss"
public enum KinescopeVideoDuration: String {

    case inTenMinute = "m:ss"
    case inHour = "mm:ss"
    case inTenHours = "H:mm:ss"
    case inDay = "HH:mm:ss"

    static func from(raw duration: TimeInterval) -> KinescopeVideoDuration {
        switch duration {
        case 0..<600:
            return inTenMinute
        case 600..<3600:
            return inHour
        case 3600..<36000:
            return inTenHours
        default:
            return inDay
        }
    }

}
