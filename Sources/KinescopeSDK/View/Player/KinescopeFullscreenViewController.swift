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
    weak var returnAnchor: UIView?
    /// Where the inline player view lived. Fullscreen moves that same view, so the
    /// AVPlayerLayer is not recreated. A new layer keeps the audio and drops the picture.
    private var playerSlot: PlayerSlot?
    private var hostConstraints: [NSLayoutConstraint] = []
    /// The inline outlet is weak. Hold the view while it is between hierarchies.
    private var hostedPlayerView: KinescopePlayerView?
    /// Same orientation as the inline player. A different orientation uses the system rotation.
    var scalesFromSource = false
    /// While exiting a rotated fullscreen, report the inline orientation so the window
    /// turns upright before the video leaves the screen.
    var dismissOrientationMask: UIInterfaceOrientationMask?
    var pendingDismissActive = false
    var onRotationEnded: (() -> Void)?

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
        dismissOrientationMask ?? config.orientationMask
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

    public override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        .fade
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }

    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        // Rotation brings the navigation bar back. Keep the top band off until fullscreen is gone.
        hidePresenterChrome()
        // Keep the pause card and the seek bar off while the video is turning.
        playerView.holdsControlReveal = true
        playerView.dismissTransientChrome()
        coordinator.animate(alongsideTransition: { _ in
            self.hidePresenterChrome()
        }, completion: { [weak self] context in
            guard let self else {
                return
            }
            if context.isCancelled {
                self.playerView.holdsControlReveal = false
                self.playerView.revealControls(autoHide: (self.player as? KinescopeVideoPlayer)?.isPlaying ?? false)
                return
            }
            let end = self.onRotationEnded
            self.onRotationEnded = nil
            if self.pendingDismissActive {
                end?()
                return
            }
            self.playerView.holdsControlReveal = false
            self.playerView.revealControls(autoHide: (self.player as? KinescopeVideoPlayer)?.isPlaying ?? false)
            end?()
        })
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard view.transform == .identity, let superview = view.superview else {
            return
        }
        if view.frame != superview.bounds {
            view.frame = superview.bounds
        }
    }

    // MARK: - Lifecycle

    public override func viewDidLoad() {
        super.viewDidLoad()

        setupInitialState()
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if playerView.playerView.player == nil {
            player.attach(view: playerView)
        }
    }

    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        player.detach(view: playerView)
    }
}

// MARK: - Present/dismiss helper

extension KinescopeFullscreenViewController {

    private static weak var presentedInstance: KinescopeFullscreenViewController?
    private static var orientationBeforePresentation: UIInterfaceOrientation?
    private static var hidNavigationBar = false
    private(set) static var isTransitioning = false

    static var isPresented: Bool {
        presentedInstance?.presentingViewController != nil
    }

    static func dismiss(with completion: @escaping () -> Void) {
        guard let controller = presentedInstance,
              let presenting = controller.presentingViewController,
              !isTransitioning else {
            return
        }
        isTransitioning = true
        let current = controller.view.window?.windowScene?.interfaceOrientation
        let target = orientationBeforePresentation ?? .portrait
        let needsRotate = current != nil && current != target && mask(for: target) != nil
        guard needsRotate, let targetMask = mask(for: target) else {
            // Same orientation as Android: the surface switches, the fullscreen layer just goes away.
            controller.placePlayerBack()
            restoreNavigationBar(of: presenting)
            presenting.view.layoutIfNeeded()
            presenting.dismiss(animated: false) {
                isTransitioning = false
                presentedInstance = nil
                restoreOrientation(of: presenting)
                completion()
            }
            return
        }

        // Turn the still-fullscreen video upright first. Dismissing before that
        // reveals the page and its top bar sideways, then rotates them.
        controller.pendingDismissActive = true
        controller.dismissOrientationMask = targetMask
        controller.playerView.holdsControlReveal = true
        controller.playerView.dismissTransientChrome()
        controller.onRotationEnded = {
            finishDismiss(controller, presenting: presenting, completion: completion)
        }
        requestOrientation(targetMask, for: controller)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            finishDismiss(controller, presenting: presenting, completion: completion)
        }
    }

    /// Removes fullscreen only once the window matches the inline orientation.
    private static func finishDismiss(_ controller: KinescopeFullscreenViewController,
                                      presenting: UIViewController,
                                      completion: @escaping () -> Void) {
        guard controller.pendingDismissActive else {
            return
        }
        controller.pendingDismissActive = false
        controller.onRotationEnded = nil
        presenting.navigationController?.setNavigationBarHidden(true, animated: false)
        let current = controller.view.window?.windowScene?.interfaceOrientation
        let target = orientationBeforePresentation ?? .portrait
        let upright = current == target || current == nil

        let close = {
            controller.placePlayerBack()
            presenting.dismiss(animated: false) {
                isTransitioning = false
                presentedInstance = nil
                if upright {
                    orientationBeforePresentation = nil
                } else {
                    restoreOrientation(of: presenting)
                }
                restoreNavigationBar(of: presenting)
                presenting.navigationController?.view.layoutIfNeeded()
                presenting.view.layoutIfNeeded()
                completion()
            }
        }

        close()
    }

    /// Puts the same player view back into the screen it was taken from.
    func placePlayerBack() {
        guard let moved = hostedPlayerView ?? playerView else {
            return
        }
        NSLayoutConstraint.deactivate(hostConstraints)
        hostConstraints = []
        moved.removeFromSuperview()
        playerSlot?.restore(moved)
        playerSlot = nil
        hostedPlayerView = nil
    }

    static func present(player: KinescopePlayer,
                        video: KinescopeVideo,
                        from source: KinescopePlayerView,
                        with playerViewConfig: KinescopePlayerViewConfiguration,
                        and completion: @escaping () -> Void) {
        guard !isTransitioning, presentedInstance == nil else {
            return
        }
        isTransitioning = true
        let open: (KinescopeFullscreenConfiguration) -> Void = { configuration in
            guard let presenting = ForegroundWindow.topViewController else {
                isTransitioning = false
                return
            }
            let playerVC = KinescopeFullscreenViewController(player: player,
                                                             config: configuration,
                                                             playerViewConfig: playerViewConfig)
            playerVC.loadViewIfNeeded()
            playerVC.returnAnchor = source
            let windowLandscape = presenting.view.window?.windowScene?.interfaceOrientation.isLandscape ?? false
            let targetLandscape = configuration.orientation.isLandscape
            playerVC.scalesFromSource = windowLandscape == targetLandscape
            playerVC.modalPresentationStyle = .fullScreen
            playerVC.transitioningDelegate = playerVC
            playerVC.modalPresentationCapturesStatusBarAppearance = true
            presentedInstance = playerVC
            orientationBeforePresentation = presenting.view.window?.windowScene?.interfaceOrientation
            if let navigation = presenting.navigationController, !navigation.isNavigationBarHidden {
                navigation.setNavigationBarHidden(true, animated: false)
                hidNavigationBar = true
            }
            source.dismissTransientChrome()
            source.suppressControlReveal = true
            if !playerVC.scalesFromSource {
                source.holdsControlReveal = true
            }
            playerVC.adopt(source)
            // The surface is already on the fullscreen view. Landscape only rotates after that,
            // so the player rectangle does not travel into the new orientation.
            presenting.present(playerVC, animated: false) {
                isTransitioning = false
                completion()
            }
            if !playerVC.scalesFromSource {
                requestOrientation(configuration.orientationMask, for: playerVC)
            }
        }

        let size = source.playerView.player?.currentItem?.presentationSize ?? .zero
        if size.width > 1, size.height > 1 {
            open(size.width > size.height ? .landscape : .portrait)
        } else {
            KinescopeFullscreenConfiguration.preferred(for: video, completion: open)
        }
    }

    private static func restoreNavigationBar(of presenting: UIViewController) {
        guard hidNavigationBar else {
            return
        }
        hidNavigationBar = false
        presenting.navigationController?.setNavigationBarHidden(false, animated: false)
    }

    /// Since iOS 16 system doesn't rotate interface back after dismissing
    /// controller with different supported orientations, so ask it explicitly.
    private static func restoreOrientation(of presenting: UIViewController) {
        let supported = presenting.navigationController?.supportedInterfaceOrientations
            ?? presenting.supportedInterfaceOrientations
        let previous = orientationBeforePresentation.flatMap { mask(for: $0) }
        orientationBeforePresentation = nil

        let target: UIInterfaceOrientationMask
        if let previous, supported.contains(previous) {
            target = previous
        } else if supported.contains(.portrait) {
            target = .portrait
        } else {
            target = supported
        }
        requestOrientation(target, for: presenting)
    }

    private static func mask(for orientation: UIInterfaceOrientation) -> UIInterfaceOrientationMask? {
        switch orientation {
        case .portrait:
            return .portrait
        case .portraitUpsideDown:
            return .portraitUpsideDown
        case .landscapeLeft:
            return .landscapeLeft
        case .landscapeRight:
            return .landscapeRight
        default:
            return nil
        }
    }

    private static func requestOrientation(_ mask: UIInterfaceOrientationMask, for controller: UIViewController) {
        guard #available(iOS 16.0, *) else {
            UIViewController.attemptRotationToDeviceOrientation()
            return
        }
        controller.setNeedsUpdateOfSupportedInterfaceOrientations()
        controller.navigationController?.setNeedsUpdateOfSupportedInterfaceOrientations()
        controller.view.window?.windowScene?.requestGeometryUpdate(.iOS(interfaceOrientations: mask)) { error in
            Kinescope.shared.logger?.log(error: error, level: KinescopeLoggerLevel.player)
        }
    }
}

// MARK: - Transition

extension KinescopeFullscreenViewController: UIViewControllerTransitioningDelegate {

    public func animationController(forPresented presented: UIViewController,
                                    presenting: UIViewController,
                                    source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        nil
    }

    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        nil
    }

}

// MARK: - Private

private extension KinescopeFullscreenViewController {

    func hidePresenterChrome() {
        presentingViewController?.navigationController?.setNavigationBarHidden(true, animated: false)
        setNeedsStatusBarAppearanceUpdate()
    }

    func setupInitialState() {
        view.backgroundColor = config.backgroundColor
        view.insetsLayoutMarginsFromSafeArea = false
    }

    func adopt(_ source: KinescopePlayerView) {
        playerSlot = PlayerSlot.capture(source)
        hostedPlayerView = source
        source.removeFromSuperview()
        view.addSubview(source)
        source.translatesAutoresizingMaskIntoConstraints = false
        let pinned = [
            source.topAnchor.constraint(equalTo: view.topAnchor),
            source.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            source.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            source.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ]
        hostConstraints = pinned
        NSLayoutConstraint.activate(pinned)
        playerView = source
        view.layoutIfNeeded()
    }

}

/// Inline position of the player view, so fullscreen can give it back unchanged.
private struct PlayerSlot {
    weak var superview: UIView?
    let constraints: [NSLayoutConstraint]
    let sizeConstraints: [NSLayoutConstraint]
    let index: Int
    let translates: Bool
    let autoresizing: UIView.AutoresizingMask
    let frame: CGRect

    static func capture(_ view: UIView) -> PlayerSlot {
        let superview = view.superview
        let external = superview?.constraints.filter { constraint in
            constraint.firstItem as AnyObject === view || constraint.secondItem as AnyObject === view
        } ?? []
        let size = view.constraints.filter { constraint in
            constraint.secondItem == nil
                && (constraint.firstAttribute == .height || constraint.firstAttribute == .width)
        }
        NSLayoutConstraint.deactivate(external + size)
        let index = superview?.subviews.firstIndex(of: view) ?? 0
        return PlayerSlot(superview: superview,
                          constraints: external,
                          sizeConstraints: size,
                          index: index,
                          translates: view.translatesAutoresizingMaskIntoConstraints,
                          autoresizing: view.autoresizingMask,
                          frame: view.frame)
    }

    func restore(_ view: UIView) {
        guard let superview else {
            return
        }
        view.translatesAutoresizingMaskIntoConstraints = translates
        view.autoresizingMask = autoresizing
        superview.insertSubview(view, at: min(index, superview.subviews.count))
        if translates {
            view.frame = frame
        } else {
            NSLayoutConstraint.activate(constraints + sizeConstraints)
        }
        superview.layoutIfNeeded()
    }
}
