//
//  KinescopePlayerViewConfiguration.swift
//  KinescopeSDK
//
//  Created by Никита Коробейников on 30.03.2021.
//

import AVFoundation
import UIKit

/// Appearance preferences of player view
public struct KinescopePlayerViewConfiguration {
    
    let gravity: AVLayerVideoGravity
    let previewService: PreviewService?
    let activityIndicator: KinescopeActivityIndicator
    let overlay: KinescopePlayerOverlayConfiguration?
    let controlPanel: KinescopeControlPanelConfiguration?
    let errorOverlay: KinescopeErrorConfiguration?
    let sideMenu: KinescopeSideMenuConfiguration
    let shadowOverlay: KinescopePlayerShadowOverlayConfiguration?
    let announceSnack: KinescopeAnnounceConfiguration
    
    /// - parameter gravity: `AVLayerVideoGravity` value defines how the video is displayed within a layer’s bounds rectangle
    /// - parameter previewService: Implementation of service to load posters into imageView. Set `nil` to disable previews.
    /// - parameter activityIndicator: Custom indicator view used to indicate process of video downloading
    /// - parameter overlay: Configuration of overlay with tapGesture to play/pause video
    ///  Set `nil` to hide overlay (usefull for videos collection with autoplaying)
    /// - parameter controlPanel: Configuration of control panel with play/pause buttons and other controls
    /// Set `nil` to hide control panel
    /// - parameter errorOverlay: Configuration for error view
    /// Set `nil` to hide control panel
    /// - parameter sideMenu: Configuration of side menu with setings
    /// - parameter shadowOverlay: Configuration of shadow overlay beneath side menu
    /// - parameter announceSnack: Configuration of snack bar to announce events.
    public init(gravity: AVLayerVideoGravity,
                previewService: PreviewService?,
                activityIndicator: KinescopeActivityIndicator,
                overlay: KinescopePlayerOverlayConfiguration?,
                controlPanel: KinescopeControlPanelConfiguration?,
                errorOverlay: KinescopeErrorConfiguration?,
                sideMenu: KinescopeSideMenuConfiguration,
                shadowOverlay: KinescopePlayerShadowOverlayConfiguration?,
                announceSnack: KinescopeAnnounceConfiguration) {
        self.gravity = gravity
        self.previewService = previewService
        self.activityIndicator = activityIndicator
        self.overlay = overlay
        self.controlPanel = controlPanel
        self.errorOverlay = errorOverlay
        self.sideMenu = sideMenu
        self.shadowOverlay = shadowOverlay
        self.announceSnack = announceSnack
    }
    
}

// MARK: - Defaults

public extension KinescopePlayerViewConfiguration {
    
    static let `default`: KinescopePlayerViewConfiguration = .init(
        gravity: .resizeAspect,
        previewService: PreviewNetworkService(),
        activityIndicator: UIActivityIndicatorView(style: .whiteLarge),
        overlay: .default,
        controlPanel: .default,
        errorOverlay: .default,
        sideMenu: .default,
        shadowOverlay: .default,
        announceSnack: .default
    )
    
}

// MARK: - Builder

public class KinescopePlayerViewConfigurationBuilder {
    
    private var gravity: AVLayerVideoGravity
    private var previewService: PreviewService?
    private var activityIndicator: KinescopeActivityIndicator
    private var overlay: KinescopePlayerOverlayConfiguration?
    private var controlPanel: KinescopeControlPanelConfiguration?
    private var errorOverlay: KinescopeErrorConfiguration?
    private var sideMenu: KinescopeSideMenuConfiguration
    private var shadowOverlay: KinescopePlayerShadowOverlayConfiguration?
    private var announceSnack: KinescopeAnnounceConfiguration
    
    public init(configuration: KinescopePlayerViewConfiguration = .default) {
        self.gravity = configuration.gravity
        self.previewService = configuration.previewService
        self.activityIndicator = configuration.activityIndicator
        self.overlay = configuration.overlay
        self.controlPanel = configuration.controlPanel
        self.errorOverlay = configuration.errorOverlay
        self.sideMenu = configuration.sideMenu
        self.shadowOverlay = configuration.shadowOverlay
        self.announceSnack = configuration.announceSnack
    }
    
    public func setGravity(_ gravity: AVLayerVideoGravity) -> Self {
        self.gravity = gravity
        return self
    }
    
    public func setPreviewService(_ previewService: PreviewService?) -> Self {
        self.previewService = previewService
        return self
    }
    
    public func setActivityIndicator(_ activityIndicator: KinescopeActivityIndicator) -> Self {
        self.activityIndicator = activityIndicator
        return self
    }
    
    public func setOverlay(_ overlay: KinescopePlayerOverlayConfiguration?) -> Self {
        self.overlay = overlay
        return self
    }
    
    public func setControlPanel(_ controlPanel: KinescopeControlPanelConfiguration?) -> Self {
        self.controlPanel = controlPanel
        return self
    }
    
    public func setErrorOverlay(_ errorOverlay: KinescopeErrorConfiguration?) -> Self {
        self.errorOverlay = errorOverlay
        return self
    }
    
    public func setSideMenu(_ sideMenu: KinescopeSideMenuConfiguration) -> Self {
        self.sideMenu = sideMenu
        return self
    }
    
    public func setShadowOverlay(_ shadowOverlay: KinescopePlayerShadowOverlayConfiguration?) -> Self {
        self.shadowOverlay = shadowOverlay
        return self
    }
    
    public func setAnnounceSnack(_ announceSnack: KinescopeAnnounceConfiguration) -> Self {
        self.announceSnack = announceSnack
        return self
    }
    
    public func build() -> KinescopePlayerViewConfiguration {
        .init(
            gravity: gravity,
            previewService: previewService,
            activityIndicator: activityIndicator,
            overlay: overlay,
            controlPanel: controlPanel,
            errorOverlay: errorOverlay,
            sideMenu: sideMenu,
            shadowOverlay: shadowOverlay,
            announceSnack: announceSnack
        )
    }
}
