//
//  PipManager.swift
//  KinescopeExample
//
//  Created by Никита Гагаринов on 22.04.2021.
//

import AVKit

/// Holds strong reference to AVPictureInPictureController in order to keep playing in pip after view will be deinited
final class PipManager: NSObject, AVPictureInPictureControllerDelegate {

    // MARK: - Singleton

    static let shared = PipManager()
    
    // MARK: - Properties

    private var pipController: AVPictureInPictureController?
    private var currentVideoId = ""
    private var plaingVideoId = ""

    // MARK: - Initialization

    private override init() {}

    /// Close Pip if opened same video
    func closePipIfNeeded(with videoId: String) {
        currentVideoId = videoId
        if currentVideoId == plaingVideoId {
            pipController?.stopPictureInPicture()
        }
    }

    // MARK: - AVPictureInPictureControllerDelegate

    func pictureInPictureControllerWillStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        plaingVideoId = currentVideoId
        self.pipController = pictureInPictureController
    }

    func pictureInPictureControllerDidStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        self.pipController = nil
        self.plaingVideoId = ""
    }

}
