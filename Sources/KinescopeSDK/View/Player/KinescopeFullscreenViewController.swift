//
//  KinescopeFullscreenViewController.swift
//  KinescopeSDK
//
//  Created by Никита Коробейников on 02.04.2021.
//
// swiftlint:disable implicitly_unwrapped_optional

import UIKit

final public class KinescopeFullscreenViewController: UIViewController {

    // MARK: - Private properties

    private weak var playerView: KinescopePlayerView!

    private var player: KinescopePlayer!

    private let config: KinescopeFullscreenConfiguration
    private let playerViewConfig: KinescopePlayerViewConfiguration

    // MARK: - Init

    public init(player: KinescopePlayer, 
                config: KinescopeFullscreenConfiguration,
                playerViewConfig: KinescopePlayerViewConfiguration) {
        self.player = player
        self.config = config
        self.playerViewConfig = playerViewConfig
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

// MARK: - Present/dismiss helper

extension KinescopeFullscreenViewController {
    
    private static var rootVC: UIViewController? {
        UIApplication.shared.keyWindow?.rootViewController
    }

    static var isPresented: Bool {
        rootVC?.presentedViewController is Self
    }

    static func dismiss(with completion: @escaping () -> Void) {
        rootVC?.dismiss(animated: true, completion: completion)
    }

    static func present(player: KinescopePlayer,
                        video: KinescopeVideo,
                        with playerViewConfig: KinescopePlayerViewConfiguration,
                        and completion: @escaping () -> Void) {
        KinescopeFullscreenConfiguration.preferred(for: video) { configuration in
            let playerVC = KinescopeFullscreenViewController(player: player,
                                                             config: configuration, 
                                                             playerViewConfig: playerViewConfig)
            playerVC.modalPresentationStyle = .overFullScreen
            playerVC.modalTransitionStyle = .crossDissolve
            playerVC.modalPresentationCapturesStatusBarAppearance = true
            rootVC?.present(playerVC, animated: true, completion: completion)
        }
    }
}

// MARK: - Private

private extension KinescopeFullscreenViewController {

    func setupInitialState() {

        view.backgroundColor = config.backgroundColor

        let playerView = KinescopePlayerView()
        playerView.setLayout(with: playerViewConfig)
        view.addSubview(playerView)
        view.stretch(view: playerView)

        self.playerView = playerView
    }

}
