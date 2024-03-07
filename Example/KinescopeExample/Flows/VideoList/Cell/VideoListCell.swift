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

    private var player: KinescopePlayer?

    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none

        playerView.backgroundColor = .black
        playerView.layer.cornerRadius = 20
        playerView.layer.masksToBounds = true
        playerView.setLayout(with: .init(gravity: .resizeAspect,
                                         activityIndicator: UIActivityIndicatorView(style: .white),
                                         overlay: nil,
                                         controlPanel: nil,
                                         sideMenu: .default,
                                         shadowOverlay: .default))
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        player?.detach(view: playerView)
    }

    // MARK: - Public Methods

    func start() {
        player?.play()
    }

    func stop() {
        player?.pause()
    }

}

// MARK: - ConfigurableItem

extension VideoListCell: ConfigurableItem {

    typealias Model = KinescopeVideo

    func configure(with model: Model) {

        playerView.previewView.contentMode = .scaleAspectFit
        playerView.previewView.kf.setImage(with: URL(string: model.poster?.md ?? ""))
        player = KinescopeVideoPlayer(config: .init(videoId: model.id, looped: true))
        player?.attach(view: playerView)
    }

}
