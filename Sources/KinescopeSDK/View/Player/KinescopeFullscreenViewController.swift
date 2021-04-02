//
//  KinescopeFullscreenViewController.swift
//  KinescopeSDK
//
//  Created by Никита Коробейников on 02.04.2021.
//

import UIKit

final public class KinescopeFullscreenViewController: UIViewController {

    // MARK: - IBOutlets

    private weak var playerView: KinescopePlayerView!

    // MARK: - Private properties

    private var player: KinescopePlayer!

    // MARK: - Init

    public init(player: KinescopePlayer) {
        self.player = player
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Orientation style

    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        .landscapeRight
    }

    public override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        .landscapeRight
    }

    // MARK: - Lifecycle

    public override func viewDidLoad() {
        super.viewDidLoad()

        setupInitialState()
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        player.attach(view: playerView)
        player.play()
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        player.detach(view: playerView)
    }

    public override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        if parent == nil {
            player.detach(view: playerView)
        }
    }
}

// MARK: - Private

private extension KinescopeFullscreenViewController {

    func setupInitialState() {

        let playerView = KinescopePlayerView()
        playerView.setLayout(with: .default)
        view.addSubview(playerView)
        view.stretch(view: playerView)

        self.playerView = playerView
    }

}
