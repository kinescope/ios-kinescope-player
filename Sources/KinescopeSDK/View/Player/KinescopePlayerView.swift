//
//  KinescopePlayerView.swift
//  KinescopeSDK
//
//  Created by Никита Коробейников on 23.03.2021.
//
// swiftlint:disable implicitly_unwrapped_optional

import UIKit
import AVFoundation

public class KinescopePlayerView: UIView {

    // MARK: - Private Properties

    /// View with AVPlayerLayer to fill size
    var playerView: PlayerView!
    var playerControlView: PlayerControlView!

    // MARK: - Internal Properties

    ///
    public private(set) var previewView: UIImageView = UIImageView()

    // MARK: - Public Properties

    public var progressview: UIActivityIndicatorView!

    public var player: KinescopePlayer? {
        didSet {
            // Bind player with player view
            // KinescopePlayer should provide AVPlayer for playerView
        }
    }

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupInitialState()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupInitialState()
    }

    private func setupInitialState() {
        addSubview(previewView)
        stretch(view: previewView)
    }

}
