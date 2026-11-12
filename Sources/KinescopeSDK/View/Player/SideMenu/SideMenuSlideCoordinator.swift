//
//  SideMenuSlideCoordinator.swift
//  KinescopeSDK
//
//  Created by Никита Коробейников on 05.04.2021.
//

import UIKit

/// Settings card above the control bar. Nested screens slide inside the card, and its height follows the list.
struct SideMenuSlideCoordinator: SideMenuCoordinator {

    // MARK: - Constants

    private enum Constants {
        static let navigationDuration: TimeInterval = 0.2
        static let popupDuration: TimeInterval = 0.14
        static let width: CGFloat = 280
        static let maxHeight: CGFloat = 368
        static let margin: CGFloat = 12
        static let bottomOffset: CGFloat = 56
        static let cornerRadius: CGFloat = 6
        static let boardTag = 8_140_221
        static let clipTag = 8_140_222
    }

    /// Class storage so the backdrop callback can be set without mutating the coordinator.
    final class Hooks {
        var onBackdrop: (() -> Void)?
    }

    /// In-flight step. The coordinator is a struct, so the animator lives on a class.
    final class Motion {
        var navigating = false
        var animator: UIViewPropertyAnimator?
    }

    let hooks = Hooks()
    private let motion = Motion()

    // MARK: - Methods

    func menus(anchoredTo parent: UIView) -> [SideMenu] {
        guard let board = board(for: parent) else {
            return []
        }
        let host = board.viewWithTag(Constants.clipTag) ?? board
        return host.subviews.compactMap { $0 as? SideMenu }
    }

    /// Keeps an open card inside the player after rotation or a bounds change.
    func layout(in parent: UIView) {
        guard let host = board(for: parent) else { return }
        if host.frame != parent.bounds {
            host.frame = parent.bounds
        }
        reposition(in: host)
    }

    func present(view: SideMenu, in parent: UIView, animated: Bool) {
        finishNavigation()
        let host = ensureBoard(for: parent)
        let destination = frame(for: view, in: host)
        let clip = ensureClip(in: host, background: view.backgroundColor)
        clip.alpha = 1
        let previous = menus(anchoredTo: parent).last
        prepare(view)

        guard let previous else {
            clip.frame = destination
            view.frame = clip.bounds
            view.alpha = 1
            clip.addSubview(view)
            guard animated else {
                return
            }
            clip.alpha = 0
            UIView.animate(withDuration: Constants.popupDuration) {
                clip.alpha = 1
            }
            return
        }

        let start = clip.frame
        place(previous, in: start, x: 0, panelHeight: start.height)
        previous.alpha = 1
        previous.isHidden = false
        place(view, in: start, x: start.width, panelHeight: destination.height)
        view.alpha = 0
        clip.addSubview(view)

        let step = {
            clip.frame = destination
            self.place(view, in: destination, x: 0, panelHeight: destination.height)
            view.alpha = 1
            self.place(previous, in: destination, x: -destination.width, panelHeight: start.height)
            previous.alpha = 0
        }
        guard animated else {
            step()
            previous.isHidden = true
            return
        }
        runNavigation(step) {
            previous.isHidden = true
        }
    }

    func dismiss(view: SideMenu, from parent: UIView, animated: Bool) {
        let board = board(for: parent)
        let clip = board?.viewWithTag(Constants.clipTag)
        let stack = menus(anchoredTo: parent)
        let isTop = stack.last === view
        let previous = isTop ? stack.dropLast().last : nil

        guard isTop else {
            finishNavigation()
            remove(view)
            showTopMenu(in: board)
            return
        }

        guard let board, let clip, let previous else {
            fadeOut(view, clip: clip, animated: animated)
            return
        }

        finishNavigation()
        let destination = frame(for: previous, in: board)
        let start = clip.frame
        previous.isHidden = false
        place(previous, in: start, x: -start.width, panelHeight: destination.height)
        previous.alpha = 0

        let step = {
            clip.frame = destination
            self.place(view, in: destination, x: destination.width, panelHeight: start.height)
            view.alpha = 0
            self.place(previous, in: destination, x: 0, panelHeight: destination.height)
            previous.alpha = 1
        }
        guard animated else {
            step()
            remove(view)
            return
        }
        runNavigation(step) {
            self.remove(view)
        }
    }

    private func fadeOut(_ view: SideMenu, clip: UIView?, animated: Bool) {
        finishNavigation()
        guard animated, let clip else {
            remove(view)
            return
        }
        UIView.animate(withDuration: Constants.popupDuration, animations: {
            clip.alpha = 0
        }, completion: { _ in
            self.remove(view)
        })
    }

    private func remove(_ view: SideMenu) {
        let clip = view.superview
        let board = clip?.superview
        view.removeFromSuperview()
        if clip?.subviews.isEmpty == true {
            clip?.removeFromSuperview()
        }
        if board?.subviews.isEmpty == true {
            board?.removeFromSuperview()
        }
    }

    /// Board fills the player and clips the card, so the list never draws over the page around it.
    private func ensureBoard(for player: UIView) -> UIView {
        if let board = player.viewWithTag(Constants.boardTag) {
            board.frame = player.bounds
            player.bringSubviewToFront(board)
            return board
        }
        let board = SideMenuBoard(frame: player.bounds)
        board.tag = Constants.boardTag
        board.clipsToBounds = true
        board.onBackdrop = { [hooks] in
            hooks.onBackdrop?()
        }
        player.addSubview(board)
        return board
    }

    private func board(for player: UIView) -> UIView? {
        player.viewWithTag(Constants.boardTag)
    }

    private func reposition(in board: UIView) {
        guard !motion.navigating,
              let clip = board.viewWithTag(Constants.clipTag),
              let menu = clip.subviews.compactMap({ $0 as? SideMenu }).last else {
            return
        }
        let destination = frame(for: menu, in: board)
        clip.frame = destination
        menu.isHidden = false
        menu.alpha = 1
        menu.frame = clip.bounds
    }

    /// Pins a panel to the top of the card. The card's top edge moves as its height changes.
    private func place(_ menu: SideMenu, in card: CGRect, x: CGFloat, panelHeight: CGFloat) {
        menu.frame = CGRect(x: x, y: 0, width: max(card.width, 1), height: max(panelHeight, 1))
    }

    private func prepare(_ menu: SideMenu) {
        menu.autoresizingMask = []
        menu.transform = .identity
        menu.layer.cornerRadius = 0
        menu.clipsToBounds = true
    }

    private func ensureClip(in board: UIView, background: UIColor?) -> UIView {
        if let clip = board.viewWithTag(Constants.clipTag) {
            return clip
        }
        let clip = UIView()
        clip.tag = Constants.clipTag
        clip.clipsToBounds = true
        clip.layer.cornerRadius = Constants.cornerRadius
        clip.backgroundColor = background
        board.addSubview(clip)
        return clip
    }

    private func showTopMenu(in board: UIView?) {
        guard let board,
              let clip = board.viewWithTag(Constants.clipTag),
              let menu = clip.subviews.compactMap({ $0 as? SideMenu }).last else {
            return
        }
        let destination = frame(for: menu, in: board)
        clip.alpha = 1
        clip.frame = destination
        menu.isHidden = false
        menu.alpha = 1
        menu.frame = clip.bounds
    }

    private func runNavigation(_ animations: @escaping () -> Void, completion: @escaping () -> Void) {
        let animator = UIViewPropertyAnimator(
            duration: Constants.navigationDuration,
            timingParameters: UICubicTimingParameters(controlPoint1: CGPoint(x: 0.4, y: 0),
                                                      controlPoint2: CGPoint(x: 0.2, y: 1))
        )
        animator.addAnimations(animations)
        motion.navigating = true
        motion.animator = animator
        animator.addCompletion { [motion] position in
            let owns = motion.animator === animator
            if owns {
                motion.animator = nil
                motion.navigating = false
            }
            if position == .end {
                completion()
            }
        }
        animator.startAnimation()
    }

    private func finishNavigation() {
        guard let animator = motion.animator else {
            return
        }
        motion.animator = nil
        motion.navigating = false
        animator.stopAnimation(false)
        if animator.state == .stopped {
            animator.finishAnimation(at: .end)
        }
    }

    /// Card stays inside the player, above the control bar. Extra rows scroll inside the card.
    private func frame(for menu: SideMenu, in board: UIView) -> CGRect {
        let bounds = board.bounds
        let insets = board.safeAreaInsets
        let horizontalOverflow = insets.left + insets.right > bounds.width * 0.45
        let verticalOverflow = insets.bottom > bounds.height * 0.45
        let leftMin = horizontalOverflow ? Constants.margin : max(Constants.margin, insets.left)
        let right = horizontalOverflow ? Constants.margin : max(Constants.margin, insets.right)
        let topLimit = verticalOverflow ? Constants.margin : max(Constants.margin, insets.top)
        let bottom = (verticalOverflow ? 0 : insets.bottom) + Constants.bottomOffset

        let width = min(Constants.width, max(0, bounds.width - leftMin - right))
        let available = max(0, bounds.height - bottom - topLimit)
        let height = min(menu.preferredHeight, min(Constants.maxHeight, available))
        let x = max(leftMin, bounds.width - right - width)
        let y = max(topLimit, bounds.height - bottom - height)
        return CGRect(x: x, y: y, width: width, height: max(height, 0))
    }

}

/// Clear full-screen layer. Taps outside the card close the menu; taps on the card pass through.
private final class SideMenuBoard: UIView, UIGestureRecognizerDelegate {

    var onBackdrop: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        let tap = UITapGestureRecognizer(target: self, action: #selector(backdropTapped))
        tap.delegate = self
        addGestureRecognizer(tap)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc
    func backdropTapped() {
        onBackdrop?()
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        touch.view === self
    }

}
