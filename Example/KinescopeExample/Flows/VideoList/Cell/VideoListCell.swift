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

    // MARK: - Private properties

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
        // KIN-21:  start playing video inside playerView
    }

    func stop() {
        player?.pause()
        // KIN-21: - stop playing video inside playerView
    }

}

// MARK: - ConfigurableItem

extension VideoListCell: ConfigurableItem {

    typealias Model = KinescopeVideo

    func configure(with model: Model) {
        playerView.previewView.kf.setImage(with: URL(string: model.poster.md))
        player = KinescopeVideoPlayer(videoId: model.id, looped: true)
        playerView.player = player
        player?.delegate = self
    }

}

// MARK: - ConfigurableItem

extension VideoListCell: KinescopePlayerDelegate {
    func kinescopePlayerDidReadyToPlay(player: KinescopePlayer) {
        playerView.previewView.isHidden = true
        player.play()
    }

    func kinescopePlayerDataLoadingFailed(player: KinescopePlayer, error: Error) {
        playerView.previewView.isHidden = true
    }
}
