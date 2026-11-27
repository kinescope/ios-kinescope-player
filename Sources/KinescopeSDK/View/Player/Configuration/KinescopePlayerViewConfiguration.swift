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
    /// System picture-in-picture. Shorts keep this off: the feed is the only surface.
    let allowsPictureInPicture: Bool
    /// Device rotation to landscape opens fullscreen.
    /// `nil`: only when the fullscreen button is shown, as before 1.0.4.
    /// `true` or `false` works apart from the button and the control panel.
    /// Rotation back to portrait closes fullscreen whatever this value is.
    let fullscreenOnRotate: Bool?
    /// Built-in poster when the video has no poster or it fails to load.
    /// `false` leaves the view empty until playback.
    let showsDefaultPoster: Bool
    /// Poster shown when the video has none or it fails to load. `nil` uses the built-in one.
    let defaultPoster: UIImage?
    /// Cover shown while a live broadcast has not started. `nil` uses the built-in one.
    let liveAwaitingCover: UIImage?
    /// Clear backdrop behind the picture and the poster instead of black.
    let transparentBackground: Bool
    
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
    /// - parameter fullscreenOnRotate: Open fullscreen when the device turns to landscape.
    /// `nil` follows the fullscreen button.
    /// - parameter showsDefaultPoster: Built-in poster when the video has no poster of its own.
    /// - parameter defaultPoster: Your own poster in place of the built-in one. `nil` uses the built-in one.
    /// - parameter liveAwaitingCover: Your own cover while a live broadcast has not started.
    /// `nil` uses the built-in one.
    /// - parameter transparentBackground: Clear backdrop instead of black, like `transparent` in the web player embed.
    public init(gravity: AVLayerVideoGravity,
                previewService: PreviewService?,
                activityIndicator: KinescopeActivityIndicator,
                overlay: KinescopePlayerOverlayConfiguration?,
                controlPanel: KinescopeControlPanelConfiguration?,
                errorOverlay: KinescopeErrorConfiguration?,
                sideMenu: KinescopeSideMenuConfiguration,
                shadowOverlay: KinescopePlayerShadowOverlayConfiguration?,
                announceSnack: KinescopeAnnounceConfiguration,
                allowsPictureInPicture: Bool = true,
                fullscreenOnRotate: Bool? = nil,
                showsDefaultPoster: Bool = true,
                defaultPoster: UIImage? = nil,
                liveAwaitingCover: UIImage? = nil,
                transparentBackground: Bool = false) {
        self.gravity = gravity
        self.previewService = previewService
        self.activityIndicator = activityIndicator
        self.overlay = overlay
        self.controlPanel = controlPanel
        self.errorOverlay = errorOverlay
        self.sideMenu = sideMenu
        self.shadowOverlay = shadowOverlay
        self.announceSnack = announceSnack
        self.allowsPictureInPicture = allowsPictureInPicture
        self.fullscreenOnRotate = fullscreenOnRotate
        self.showsDefaultPoster = showsDefaultPoster
        self.defaultPoster = defaultPoster
        self.liveAwaitingCover = liveAwaitingCover
        self.transparentBackground = transparentBackground
    }
    
}

// MARK: - Defaults

public extension KinescopePlayerViewConfiguration {
    
    static func builder() -> KinescopePlayerViewConfigurationBuilder {
        .init(configuration: .default)
    }

    static let `default`: KinescopePlayerViewConfiguration = .init(
        gravity: .resizeAspect,
        previewService: PreviewNetworkService(),
        activityIndicator: BufferingIndicatorView(),
        overlay: .default,
        controlPanel: .default,
        errorOverlay: .default,
        sideMenu: .default,
        shadowOverlay: .default,
        announceSnack: .default,
        allowsPictureInPicture: true,
        fullscreenOnRotate: nil,
        showsDefaultPoster: true,
        defaultPoster: nil,
        liveAwaitingCover: nil,
        transparentBackground: false
    )

    /// Background video, like `background` in the web player embed: the picture only,
    /// no overlay, control panel, PiP, or fullscreen on rotate. Everything else comes from `base`.
    static func background(from base: KinescopePlayerViewConfiguration = .default) -> Self {
        KinescopePlayerViewConfigurationBuilder(configuration: base)
            .setOverlay(nil)
            .setControlPanel(nil)
            .setShadowOverlay(nil)
            .setPictureInPicture(false)
            .setFullscreenOnRotate(false)
            .build()
    }

    static func accentTimeLineAndPlayButton(with color: UIColor) -> Self {
        .builder()
            .setControlPanel(
                .builder()
                    .setTimeline(
                        .builder()
                            .setActiveColor(color)
                            .build()
                    )
                    .build()
            )
            .setOverlay(
                .builder()
                    .setPlayBackgroundColor(color)
                    .build()
            )
            .build()
    }

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
    private var allowsPictureInPicture: Bool
    private var fullscreenOnRotate: Bool?
    private var showsDefaultPoster: Bool
    private var defaultPoster: UIImage?
    private var liveAwaitingCover: UIImage?
    private var transparentBackground: Bool
    
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
        self.allowsPictureInPicture = configuration.allowsPictureInPicture
        self.fullscreenOnRotate = configuration.fullscreenOnRotate
        self.showsDefaultPoster = configuration.showsDefaultPoster
        self.defaultPoster = configuration.defaultPoster
        self.liveAwaitingCover = configuration.liveAwaitingCover
        self.transparentBackground = configuration.transparentBackground
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
    
    public func setPictureInPicture(_ enabled: Bool) -> Self {
        allowsPictureInPicture = enabled
        return self
    }

    /// Open fullscreen when the device turns to landscape.
    /// Works apart from the fullscreen button and the control panel.
    /// Unset, rotation opens fullscreen only while the fullscreen button is shown.
    public func setFullscreenOnRotate(_ enabled: Bool) -> Self {
        fullscreenOnRotate = enabled
        return self
    }

    /// Built-in poster when the video has no poster or it fails to load. `true` by default.
    /// `false` leaves the view empty until playback.
    public func setShowsDefaultPoster(_ shows: Bool) -> Self {
        showsDefaultPoster = shows
        return self
    }

    /// Your own poster for videos without one, and for a poster that fails to load.
    /// `nil` (default) uses the built-in one. Ignored when `setShowsDefaultPoster(false)`.
    public func setDefaultPoster(_ image: UIImage?) -> Self {
        defaultPoster = image
        return self
    }

    /// Your own cover while a live broadcast has not started. `nil` (default) uses the built-in one.
    public func setLiveAwaitingCover(_ image: UIImage?) -> Self {
        liveAwaitingCover = image
        return self
    }

    /// Clear backdrop behind the picture and the poster instead of black, like `transparent`
    /// in the web player embed. `false` by default. Fullscreen keeps its black background.
    public func setTransparentBackground(_ transparent: Bool) -> Self {
        transparentBackground = transparent
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
            announceSnack: announceSnack,
            allowsPictureInPicture: allowsPictureInPicture,
            fullscreenOnRotate: fullscreenOnRotate,
            showsDefaultPoster: showsDefaultPoster,
            defaultPoster: defaultPoster,
            liveAwaitingCover: liveAwaitingCover,
            transparentBackground: transparentBackground
        )
    }
}
