# Types

  - [KinescopeDefaultLogger](/Documentation/KinescopeDefaultLogger.md):
    Default KinescopeLogging implementation. Based on standard output print() method
  - [KinescopeVideoPlayer](/Documentation/KinescopeVideoPlayer.md):
    KinescopePlayer implementation
  - [KinescopeFullscreenViewController](/Documentation/KinescopeFullscreenViewController.md):
    View controller with player view over fullscreen
  - [KinescopePlayerView](/Documentation/KinescopePlayerView.md):
    Main player view
  - [KinescopePreviewView](/Documentation/KinescopePreviewView.md):
    Preview View with video title, description, duration, banner and play image
  - [KinescopeSpinner](/Documentation/KinescopeSpinner.md):
    Custom loading indicator
  - [KinescopeLoggerLevel](/Documentation/KinescopeLoggerLevel.md):
    Default logger levels
  - [KinescopeVideoDuration](/Documentation/KinescopeVideoDuration.md):
    Video duration enum. Raw value - string in format: "mm:ss"
  - [KinescopeDownloadError](/Documentation/KinescopeDownloadError.md):
    Enumeration of possible negative cases while downloading content
  - [KinescopeInspectError](/Documentation/KinescopeInspectError.md):
    Enumeration of possible negative cases while downloading content
  - [KinescopePlayerOption](/Documentation/KinescopePlayerOption.md):
    Options available in player control panel
  - [KinescopeEvent](/Documentation/KinescopeEvent.md):
    Enumeration of sdk events
  - [Kinescope](/Documentation/Kinescope.md):
    Holds entry point for sdk services
  - [KinescopeFastRewind](/Documentation/KinescopeFastRewind.md):
    Fast rewind(on double tap options)
  - [KinescopeVideoNameDisplayingType](/Documentation/KinescopeVideoNameDisplayingType.md):
    Type of displaying view with title and description of video
  - [KinescopeCallState](/Documentation/KinescopeCallState.md):
    On-device calls states
  - [KinescopeVideoAssetLink](/Documentation/KinescopeVideoAssetLink.md):
    Asset link endpoint responce model
  - [KinescopeConfig](/Documentation/KinescopeConfig.md):
    Configuration entity required to connect SDK with your dashboard
  - [KinescopePlayerConfig](/Documentation/KinescopePlayerConfig.md):
    Configuration entity required to connect resource with player
  - [KinescopeStreamVideoQuality](/Documentation/KinescopeStreamVideoQuality.md):
    Quality for hls streams
  - [KinescopeAssetVideoQuality](/Documentation/KinescopeAssetVideoQuality.md):
    Quality builded from assets
  - [KinescopeMetaData](/Documentation/KinescopeMetaData.md):
    Meta data model
  - [KinescopePagination](/Documentation/KinescopePagination.md):
    Pagination model
  - [KinescopeVideo](/Documentation/KinescopeVideo.md):
    Video model
  - [KinescopeVideoAdditionalMaterial](/Documentation/KinescopeVideoAdditionalMaterial.md):
    Additional materials(of video) model
  - [KinescopeVideoAsset](/Documentation/KinescopeVideoAsset.md):
    Asset(of video) model
  - [KinescopeVideoChapter](/Documentation/KinescopeVideoChapter.md):
    Chapter(of video) model
  - [KinescopeVideoChapterItem](/Documentation/KinescopeVideoChapterItem.md):
    Chapter item(of video) mdoel
  - [KinescopeVideoPoster](/Documentation/KinescopeVideoPoster.md):
    Poster(of video) model
  - [KinescopeVideosRequest](/Documentation/KinescopeVideosRequest.md):
    Request info with sort order and requested page chunk
  - [KinescopeVideoSubtitle](/Documentation/KinescopeVideoSubtitle.md):
    Subtitle(of video) model
  - [KinescopeControlPanelConfiguration](/Documentation/KinescopeControlPanelConfiguration.md):
    Appearence preferences for control panel with timeline and settings buttons
  - [KinescopeErrorViewConfiguration](/Documentation/KinescopeErrorViewConfiguration.md):
    Appearence preferences for timeline
  - [KinescopeFullscreenConfiguration](/Documentation/KinescopeFullscreenConfiguration.md):
    Appearence preferences for title and subtitle above video
  - [KinescopePlayerOptionsConfiguration](/Documentation/KinescopePlayerOptionsConfiguration.md):
    Appearence preferences for expandable menu with options
  - [KinescopePlayerOverlayConfiguration](/Documentation/KinescopePlayerOverlayConfiguration.md):
    Appearence preferences for overlay above video
  - [KinescopePlayerShadowOverlayConfiguration](/Documentation/KinescopePlayerShadowOverlayConfiguration.md):
    Appearance of shadow overlay beneath menu
  - [KinescopePlayerTimeindicatorConfiguration](/Documentation/KinescopePlayerTimeindicatorConfiguration.md):
    Appearence preferences for time indicator
  - [KinescopePlayerTimelineConfiguration](/Documentation/KinescopePlayerTimelineConfiguration.md):
    Appearence preferences for timeline
  - [KinescopePlayerViewConfiguration](/Documentation/KinescopePlayerViewConfiguration.md):
    Appearance preferences of player view
  - [KinescopePreviewViewConfiguration](/Documentation/KinescopePreviewViewConfiguration.md):
    Appearence preferences for preview view
  - [KinescopeSideMenuBarConfiguration](/Documentation/KinescopeSideMenuBarConfiguration.md):
    Appearence preferences for sidemenu
  - [KinescopeSideMenuConfiguration](/Documentation/KinescopeSideMenuConfiguration.md):
    Appearence preferences for side menu with player settings
  - [KinescopeSideMenuItemConfiguration](/Documentation/KinescopeSideMenuItemConfiguration.md):
    Appearence preferences for labels inside SideMenu cells
  - [KinescopeVideoNameConfiguration](/Documentation/KinescopeVideoNameConfiguration.md):
    Appearence preferences for title and subtitle above video
  - [KinescopePreviewModel](/Documentation/KinescopePreviewModel.md):
    Model for displaying preview view

# Protocols

  - [KinescopeVideoQuality](/Documentation/KinescopeVideoQuality.md):
    Player item configutation
  - [KinescopeVideoPlayerDelegate](/Documentation/KinescopeVideoPlayerDelegate.md):
    Player delegate protocol
  - [KinescopeAssetDownloadable](/Documentation/KinescopeAssetDownloadable.md):
    Control protocol managing downloading of assets(concrete quality)
  - [KinescopeAssetDownloadableDelegate](/Documentation/KinescopeAssetDownloadableDelegate.md):
    Delegate protocol to listen assets download process events
  - [KinescopeAttachmentDownloadable](/Documentation/KinescopeAttachmentDownloadable.md):
    Control protocol managing downloading of attachments
  - [KinescopeAttachmentDownloadableDelegate](/Documentation/KinescopeAttachmentDownloadableDelegate.md):
    Delegate protocol to listen attachments download file process events
  - [KinescopeConfigurable](/Documentation/KinescopeConfigurable.md):
    Control protocol supporting connection between SDK and dashboard
  - [KinescopeEventsCenter](/Documentation/KinescopeEventsCenter.md):
    Interface for events center
  - [KinescopeInspectable](/Documentation/KinescopeInspectable.md):
    Protocol managing inspectations of dashboard content like videos, projects etc
  - [KinescopeLoggingLevel](/Documentation/KinescopeLoggingLevel.md):
    Interface for logging type
  - [KinescopeLogging](/Documentation/KinescopeLogging.md):
    Interface for logging
  - [KinescopePlayer](/Documentation/KinescopePlayer.md):
    Control protocol for player
  - [KinescopePlayerConfigurable](/Documentation/KinescopePlayerConfigurable.md):
    Control protocol for configuration of player
  - [KinescopeServicesProvider](/Documentation/KinescopeServicesProvider.md):
    Provider of services working with kinescope api and events
  - [KinescopeVideoDownloadable](/Documentation/KinescopeVideoDownloadable.md):
    Control protocol managing downloading of assets and videos
  - [KinescopeVideoDownloadableDelegate](/Documentation/KinescopeVideoDownloadableDelegate.md):
    Delegate protocol to listen videos download process events
  - [KinescopeActivityIndicating](/Documentation/KinescopeActivityIndicating.md):
    Abstraction for activity indicator used to indicate process of video downloading
  - [KinescopePreviewViewDelegate](/Documentation/KinescopePreviewViewDelegate.md)

# Global Typealiases

  - [KinescopeActivityIndicator](/Documentation/KinescopeActivityIndicator.md):
    Alias for view implementing `KinescopeActivityIndicating`
