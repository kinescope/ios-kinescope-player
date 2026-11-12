//
//  KinescopePlayerBody.swift
//  KinescopeSDK
//
//  Created by Nikita Korobeinikov on 26.02.2024.
//

import Foundation

protocol KinescopePlayerBody: AnyObject {
    
    var video: KinescopeVideo? { get }

    var isLive: Bool { get }

    var strategy: PlayingStrategy { get }

    /// False after the viewer pauses, so a retry must not start playback on its own.
    var wantsPlayback: Bool { get }

    var view: KinescopePlayerView? { get }

    var delegate: KinescopeVideoPlayerDelegate? { get }

}
