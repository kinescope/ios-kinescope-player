//
//  NotificationSubKey.swift
//  KinescopeSDK
//
//  Created by Nikita Korobeinikov on 26.02.2024.
//

import Foundation
import AVFoundation

enum NotificationSubKey {

    case appWillEnterForeground
    case appDidEnterBackground
    case deviceOrientationChanged
    case itemPlaybackStaled
    
    var notificationName: NSNotification.Name {
        switch self {
        case .appWillEnterForeground:
            return UIApplication.willEnterForegroundNotification
        case .appDidEnterBackground:
            return UIApplication.didEnterBackgroundNotification
        case .deviceOrientationChanged:
            return UIDevice.orientationDidChangeNotification
        case .itemPlaybackStaled:
            return AVPlayerItem.playbackStalledNotification
        }
    }

}
