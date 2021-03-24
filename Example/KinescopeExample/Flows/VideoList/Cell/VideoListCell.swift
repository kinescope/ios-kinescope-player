//
//  VideoListCell.swift
//  KinescopeExample
//
//  Created by Никита Коробейников on 23.03.2021.
//

import UIKit
import ReactiveDataDisplayManager
import KinescopeSDK

final class VideoListCell: UITableViewCell {

    // MARK: - IBOutlets

    @IBOutlet private weak var playerView: KinescopePlayerView!

    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        playerView.backgroundColor = .green
        playerView.layer.cornerRadius = 20
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        
        playerView.player = nil
    }

    // MARK: - Public Methods

    func start() {
        playerView?.player?.play()
    }

    func stop() {
        playerView?.player?.stop()
    }

}

// MARK: - ConfigurableItem

extension VideoListCell: ConfigurableItem {

    struct Model {
//        let player: KinescopePlayer
        let title: String
    }

    func configure(with model: Model) {
//        playerView.player = model.player
    }

}

