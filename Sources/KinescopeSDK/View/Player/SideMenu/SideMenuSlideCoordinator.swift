//
//  SideMenuSlideCoordinator.swift
//  KinescopeSDK
//
//  Created by Никита Коробейников on 05.04.2021.
//

import UIKit

/// SideMenuCoordinator implementation with sliding behavior
struct SideMenuSlideCoordinator: SideMenuCoordinator {

    // MARK: - Constants

    private enum Constants {
        static let animationDuration: TimeInterval = 0.25
    }

    // MARK: - Methods

    func present(view: SideMenu, in parent: UIView, animated: Bool) {
        parent.addSubview(view)

        let width = CGFloat.minimum(parent.frame.width, UIScreen.main.bounds.height)

        view.frame = .init(origin: .init(x: parent.frame.width, y: 0),
                           size: .init(width: width, height: parent.frame.height))

        let destinationOrigin = CGPoint(x: parent.frame.width - width, y: 0)

        if animated {
            UIView.animate(withDuration: Constants.animationDuration,
                           animations: { [weak view] in
                            view?.frame.origin = destinationOrigin
                           })
        } else {
            view.frame.origin = destinationOrigin
        }
    }

    func dismiss(view: SideMenu, from parent: UIView, animated: Bool) {

        let destinationOrigin = CGPoint(x: parent.frame.width, y: 0)

        if animated {
            UIView.animate(withDuration: Constants.animationDuration,
                           animations: { [weak view] in
                            view?.frame.origin = destinationOrigin
                           },
                           completion: { [weak view] _ in
                            view?.removeFromSuperview()
                           })
        } else {
            view.removeFromSuperview()
        }

    }

}
