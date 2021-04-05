//
//  SideMenuCoordinator.swift
//  KinescopeSDK
//
//  Created by Никита Коробейников on 05.04.2021.
//

import UIKit

/// Coordinator for SideMenu presentation
protocol SideMenuCoordinator {

    /// Present side menu in parent
    ///
    /// - parameter view: side menu to present
    /// - parameter parent: parent view to add side menu as subview
    /// - parameter animated: If value is `true` than presenting will be applied with animation
    func present(view: SideMenu, in parent: UIView, animated: Bool)

    // Dismiss side menu from parent
    ///
    /// - parameter view: side menu to hide
    /// - parameter parent: parent view to remove side menu from subviews
    /// - parameter animated: If value is `true` than dismissing will be applied with animation
    func dismiss(view: SideMenu, from parent: UIView, animated: Bool)

}
