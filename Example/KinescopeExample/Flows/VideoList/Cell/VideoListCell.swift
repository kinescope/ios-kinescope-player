//
//  VideoListCell.swift
//  KinescopeExample
//
//  Created by Никита Коробейников on 23.03.2021.
//

import UIKit
import ReactiveDataDisplayManager
import KinescopeSDK
import Kingfisher

final class VideoListCell: UITableViewCell {

    // MARK: - IBOutlets

    @IBOutlet private weak var playerView: KinescopePlayerView!

    // MARK: - Properties

    // TODO: - Remove
    private var name: String = ""

    private var player: KinescopePlayer?

    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none

        playerView.backgroundColor = .green
        playerView.layer.cornerRadius = 20
        playerView.layer.masksToBounds = true
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        playerView.player = nil
    }

    // MARK: - Public Methods

    func start() {
        player?.play()
        playerView.previewView.isHidden = true
    }

    func stop() {
        player?.pause()
        playerView.previewView.isHidden = false
    }

}

// MARK: - ConfigurableItem

extension VideoListCell: ConfigurableItem {

    typealias Model = KinescopeVideo

    func configure(with model: Model) {
        name = model.title

        playerView.previewView.kf.setImage(with: URL(string: model.poster.md))

        player = KinescopeVideoPlayer(videoId: model.id, looped: true)
        playerView.player = player
    }

}
