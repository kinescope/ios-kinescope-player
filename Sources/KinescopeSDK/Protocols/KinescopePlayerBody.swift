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

    var view: KinescopePlayerView? { get }

    var delegate: KinescopeVideoPlayerDelegate? { get }

}
