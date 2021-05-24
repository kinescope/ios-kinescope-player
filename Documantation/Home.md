# Types

  - [KinescopeDefaultLogger](/KinescopeDefaultLogger):
    Default KinescopeLogging implementation. Based on standard output print() method
  - [KinescopeVideoPlayer](/KinescopeVideoPlayer):
    KinescopePlayer implementation
  - [KinescopeFullscreenViewController](/KinescopeFullscreenViewController):
    View controller with player view over fullscreen
  - [KinescopePlayerView](/KinescopePlayerView):
    Main player view
  - [KinescopePreviewView](/KinescopePreviewView):
    Preview View with video title, description, duration, banner and play image
  - [KinescopeSpinner](/KinescopeSpinner):
    Custom loading indicator
  - [KinescopeLoggerLevel](/KinescopeLoggerLevel):
    Default logger levels
  - [KinescopeVideoDuration](/KinescopeVideoDuration):
    Video duration enum. Raw value - string in format: "mm:ss"
  - [KinescopeDownloadError](/KinescopeDownloadError):
    Enumeration of possible negative cases while downloading content
  - [KinescopeInspectError](/KinescopeInspectError):
    Enumeration of possible negative cases while downloading content
  - [KinescopePlayerOption](/KinescopePlayerOption):
    Options available in player control panel
  - [KinescopeEvent](/KinescopeEvent):
    Enumeration of sdk events
  - [Kinescope](/Kinescope):
    Holds entry point for sdk services
  - [KinescopeFastRewind](/KinescopeFastRewind):
    Fast rewind(on double tap options)
  - [KinescopeVideoNameDisplayingType](/KinescopeVideoNameDisplayingType):
    Type of displaying view with title and description of video
  - [KinescopeCallState](/KinescopeCallState):
    On-device calls states
  - [KinescopeVideoAssetLink](/KinescopeVideoAssetLink):
    Asset link endpoint responce model
  - [KinescopeConfig](/KinescopeConfig):
    Configuration entity required to connect SDK with your dashboard
  - [KinescopePlayerConfig](/KinescopePlayerConfig):
    Configuration entity required to connect resource with player
  - [KinescopeStreamVideoQuality](/KinescopeStreamVideoQuality):
    Quality for hls streams
  - [KinescopeAssetVideoQuality](/KinescopeAssetVideoQuality):
    Quality builded from assets
  - [KinescopeMetaData](/KinescopeMetaData):
    Meta data model
  - [KinescopePagination](/KinescopePagination):
    Pagination model
  - [KinescopeVideo](/KinescopeVideo):
    Video model
  - [KinescopeVideoAdditionalMaterial](/KinescopeVideoAdditionalMaterial):
    Additional materials(of video) model
  - [KinescopeVideoAsset](/KinescopeVideoAsset):
    Asset(of video) model
  - [KinescopeVideoChapter](/KinescopeVideoChapter):
    Chapter(of video) model
  - [KinescopeVideoChapterItem](/KinescopeVideoChapterItem):
    Chapter item(of video) mdoel
  - [KinescopeVideoPoster](/KinescopeVideoPoster):
    Poster(of video) model
  - [KinescopeVideosRequest](/KinescopeVideosRequest):
    Request info with sort order and requested page chunk
  - [KinescopeVideoSubtitle](/KinescopeVideoSubtitle):
    Subtitle(of video) model
  - [KinescopeControlPanelConfiguration](/KinescopeControlPanelConfiguration):
    Appearence preferences for control panel with timeline and settings buttons
  - [KinescopeErrorViewConfiguration](/KinescopeErrorViewConfiguration):
    Appearence preferences for timeline
  - [KinescopeFullscreenConfiguration](/KinescopeFullscreenConfiguration):
    Appearence preferences for title and subtitle above video
  - [KinescopePlayerOptionsConfiguration](/KinescopePlayerOptionsConfiguration):
    Appearence preferences for expandable menu with options
  - [KinescopePlayerOverlayConfiguration](/KinescopePlayerOverlayConfiguration):
    Appearence preferences for overlay above video
  - [KinescopePlayerShadowOverlayConfiguration](/KinescopePlayerShadowOverlayConfiguration):
    Appearance of shadow overlay beneath menu
  - [KinescopePlayerTimeindicatorConfiguration](/KinescopePlayerTimeindicatorConfiguration):
    Appearence preferences for time indicator
  - [KinescopePlayerTimelineConfiguration](/KinescopePlayerTimelineConfiguration):
    Appearence preferences for timeline
  - [KinescopePlayerViewConfiguration](/KinescopePlayerViewConfiguration):
    Appearance preferences of player view
  - [KinescopePreviewViewConfiguration](/KinescopePreviewViewConfiguration):
    Appearence preferences for preview view
  - [KinescopeSideMenuBarConfiguration](/KinescopeSideMenuBarConfiguration):
    Appearence preferences for sidemenu
  - [KinescopeSideMenuConfiguration](/KinescopeSideMenuConfiguration):
    Appearence preferences for side menu with player settings
  - [KinescopeSideMenuItemConfiguration](/KinescopeSideMenuItemConfiguration):
    Appearence preferences for labels inside SideMenu cells
  - [KinescopeVideoNameConfiguration](/KinescopeVideoNameConfiguration):
    Appearence preferences for title and subtitle above video
  - [KinescopePreviewModel](/KinescopePreviewModel):
    Model for displaying preview view

# Protocols

  - [KinescopeVideoQuality](/KinescopeVideoQuality):
    Player item configutation
  - [KinescopeVideoPlayerDelegate](/KinescopeVideoPlayerDelegate):
    Player delegate protocol
  - [KinescopeAssetDownloadable](/KinescopeAssetDownloadable):
    Control protocol managing downloading of assets(concrete quality)
  - [KinescopeAssetDownloadableDelegate](/KinescopeAssetDownloadableDelegate):
    Delegate protocol to listen assets download process events
  - [KinescopeAttachmentDownloadable](/KinescopeAttachmentDownloadable):
    Control protocol managing downloading of attachments
  - [KinescopeAttachmentDownloadableDelegate](/KinescopeAttachmentDownloadableDelegate):
    Delegate protocol to listen attachments download file process events
  - [KinescopeConfigurable](/KinescopeConfigurable):
    Control protocol supporting connection between SDK and dashboard
  - [KinescopeEventsCenter](/KinescopeEventsCenter):
    Interface for events center
  - [KinescopeInspectable](/KinescopeInspectable):
    Protocol managing inspectations of dashboard content like videos, projects etc
  - [KinescopeLoggingLevel](/KinescopeLoggingLevel):
    Interface for logging type
  - [KinescopeLogging](/KinescopeLogging):
    Interface for logging
  - [KinescopePlayer](/KinescopePlayer):
    Control protocol for player
  - [KinescopePlayerConfigurable](/KinescopePlayerConfigurable):
    Control protocol for configuration of player
  - [KinescopeServicesProvider](/KinescopeServicesProvider):
    Provider of services working with kinescope api and events
  - [KinescopeVideoDownloadable](/KinescopeVideoDownloadable):
    Control protocol managing downloading of assets and videos
  - [KinescopeVideoDownloadableDelegate](/KinescopeVideoDownloadableDelegate):
    Delegate protocol to listen videos download process events
  - [KinescopeActivityIndicating](/KinescopeActivityIndicating):
    Abstraction for activity indicator used to indicate process of video downloading
  - [KinescopePreviewViewDelegate](/KinescopePreviewViewDelegate)

# Global Typealiases

  - [KinescopeActivityIndicator](/KinescopeActivityIndicator):
    Alias for view implementing `KinescopeActivityIndicating`
