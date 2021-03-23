//
//  KinescopePlayerView.swift
//  KinescopeSDK
//
//  Created by Никита Коробейников on 23.03.2021.
//

import UIKit
import AVFoundation

public class KinescopePlayerView: UIView {

    // MARK: - Private Properties

    var playerView: PlayerView!
    var playerControlView: PlayerControlView!

    // MARK: - Internal Properties

    ///
    public private(set) var previewView: UIImageView!

    // MARK: - Public Properties

    public var progressview: UIActivityIndicatorView!

}
