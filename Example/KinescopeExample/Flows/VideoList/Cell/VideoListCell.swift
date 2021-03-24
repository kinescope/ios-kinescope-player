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
        // TODO: - start playing video inside playerView
    }

    func stop() {
        // TODO: - stop playing video inside playerView
    }

}

// MARK: - ConfigurableItem

extension VideoListCell: ConfigurableItem {

    typealias Model = KinescopeVideo

    func configure(with model: Model) {
//        playerView.player = model.player
    }

}

