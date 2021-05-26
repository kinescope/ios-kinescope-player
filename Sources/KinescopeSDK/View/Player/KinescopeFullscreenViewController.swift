//
//  KinescopeFullscreenViewController.swift
//  KinescopeSDK
//
//  Created by Никита Коробейников on 02.04.2021.
//
// swiftlint:disable implicitly_unwrapped_optional

import UIKit

/// View controller with player view over fullscreen
final public class KinescopeFullscreenViewController: UIViewController {

    // MARK: - Private properties

    private weak var playerView: KinescopePlayerView!

    private var player: KinescopePlayer!

    private let config: KinescopeFullscreenConfiguration

    // MARK: - Init

    /// - Parameters:
    ///   - player: Kinescope player instance to manage attach/detach actions
    ///   - config: configuration
    public init(player: KinescopePlayer, config: KinescopeFullscreenConfiguration) {
        self.player = player
        self.config = config
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Orientation style

    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        config.orientationMask
    }

    public override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        config.orientation
    }

    public override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }

    public override var prefersStatusBarHidden: Bool {
        return true
    }

    // MARK: - Lifecycle

    public override func viewDidLoad() {
        super.viewDidLoad()

        setupInitialState()
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        player.attach(view: playerView)
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

        view.backgroundColor = config.backgroundColor

        let playerView = KinescopePlayerView()
        playerView.setLayout(with: .default)
        view.addSubview(playerView)
        view.stretch(view: playerView)

        self.playerView = playerView
    }

}
