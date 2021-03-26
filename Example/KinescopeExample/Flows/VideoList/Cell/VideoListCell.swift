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
        print("KIN - START - play video with name: \(name)")
        player?.play()
    }

    func stop() {
        // KIN-21: - stop playing video inside playerView
        print("KIN - STOP -  play video with name: \(name)")
        player?.pause()
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
