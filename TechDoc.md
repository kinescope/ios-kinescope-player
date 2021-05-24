# Types

  - [KinescopeDefaultLogger](/Documentation/KinescopeDefaultLogger):
    Default KinescopeLogging implementation. Based on standard output print() method
  - [KinescopeVideoPlayer](/Documentation/KinescopeVideoPlayer):
    KinescopePlayer implementation
  - [KinescopeFullscreenViewController](/Documentation/KinescopeFullscreenViewController):
    View controller with player view over fullscreen
  - [KinescopePlayerView](/Documentation/KinescopePlayerView):
    Main player view
  - [KinescopePreviewView](/Documentation/KinescopePreviewView):
    Preview View with video title, description, duration, banner and play image
  - [KinescopeSpinner](/Documentation/KinescopeSpinner):
    Custom loading indicator
  - [KinescopeLoggerLevel](/Documentation/KinescopeLoggerLevel):
    Default logger levels
  - [KinescopeVideoDuration](/Documentation/KinescopeVideoDuration):
    Video duration enum. Raw value - string in format: "mm:ss"
  - [KinescopeDownloadError](/Documentation/KinescopeDownloadError):
    Enumeration of possible negative cases while downloading content
  - [KinescopeInspectError](/Documentation/KinescopeInspectError):
    Enumeration of possible negative cases while downloading content
  - [KinescopePlayerOption](/Documentation/KinescopePlayerOption):
    Options available in player control panel
  - [KinescopeEvent](/Documentation/KinescopeEvent):
    Enumeration of sdk events
  - [Kinescope](/Documentation/Kinescope):
    Holds entry point for sdk services
  - [KinescopeFastRewind](/Documentation/KinescopeFastRewind):
    Fast rewind(on double tap options)
  - [KinescopeVideoNameDisplayingType](/Documentation/KinescopeVideoNameDisplayingType):
    Type of displaying view with title and description of video
  - [KinescopeCallState](/Documentation/KinescopeCallState):
    On-device calls states
  - [KinescopeVideoAssetLink](/Documentation/KinescopeVideoAssetLink):
    Asset link endpoint responce model
  - [KinescopeConfig](/Documentation/KinescopeConfig):
    Configuration entity required to connect SDK with your dashboard
  - [KinescopePlayerConfig](/Documentation/KinescopePlayerConfig):
    Configuration entity required to connect resource with player
  - [KinescopeStreamVideoQuality](/Documentation/KinescopeStreamVideoQuality):
    Quality for hls streams
  - [KinescopeAssetVideoQuality](/Documentation/KinescopeAssetVideoQuality):
    Quality builded from assets
  - [KinescopeMetaData](/Documentation/KinescopeMetaData):
    Meta data model
  - [KinescopePagination](/Documentation/KinescopePagination):
    Pagination model
  - [KinescopeVideo](/Documentation/KinescopeVideo):
    Video model
  - [KinescopeVideoAdditionalMaterial](/Documentation/KinescopeVideoAdditionalMaterial):
    Additional materials(of video) model
  - [KinescopeVideoAsset](/Documentation/KinescopeVideoAsset):
    Asset(of video) model
  - [KinescopeVideoChapter](/Documentation/KinescopeVideoChapter):
    Chapter(of video) model
  - [KinescopeVideoChapterItem](/Documentation/KinescopeVideoChapterItem):
    Chapter item(of video) mdoel
  - [KinescopeVideoPoster](/Documentation/KinescopeVideoPoster):
    Poster(of video) model
  - [KinescopeVideosRequest](/Documentation/KinescopeVideosRequest):
    Request info with sort order and requested page chunk
  - [KinescopeVideoSubtitle](/Documentation/KinescopeVideoSubtitle):
    Subtitle(of video) model
  - [KinescopeControlPanelConfiguration](/Documentation/KinescopeControlPanelConfiguration):
    Appearence preferences for control panel with timeline and settings buttons
  - [KinescopeErrorViewConfiguration](/Documentation/KinescopeErrorViewConfiguration):
    Appearence preferences for timeline
  - [KinescopeFullscreenConfiguration](/Documentation/KinescopeFullscreenConfiguration):
    Appearence preferences for title and subtitle above video
  - [KinescopePlayerOptionsConfiguration](/Documentation/KinescopePlayerOptionsConfiguration):
    Appearence preferences for expandable menu with options
  - [KinescopePlayerOverlayConfiguration](/Documentation/KinescopePlayerOverlayConfiguration):
    Appearence preferences for overlay above video
  - [KinescopePlayerShadowOverlayConfiguration](/Documentation/KinescopePlayerShadowOverlayConfiguration):
    Appearance of shadow overlay beneath menu
  - [KinescopePlayerTimeindicatorConfiguration](/Documentation/KinescopePlayerTimeindicatorConfiguration):
    Appearence preferences for time indicator
  - [KinescopePlayerTimelineConfiguration](/Documentation/KinescopePlayerTimelineConfiguration):
    Appearence preferences for timeline
  - [KinescopePlayerViewConfiguration](/Documentation/KinescopePlayerViewConfiguration):
    Appearance preferences of player view
  - [KinescopePreviewViewConfiguration](/Documentation/KinescopePreviewViewConfiguration):
    Appearence preferences for preview view
  - [KinescopeSideMenuBarConfiguration](/Documentation/KinescopeSideMenuBarConfiguration):
    Appearence preferences for sidemenu
  - [KinescopeSideMenuConfiguration](/Documentation/KinescopeSideMenuConfiguration):
    Appearence preferences for side menu with player settings
  - [KinescopeSideMenuItemConfiguration](/Documentation/KinescopeSideMenuItemConfiguration):
    Appearence preferences for labels inside SideMenu cells
  - [KinescopeVideoNameConfiguration](/Documentation/KinescopeVideoNameConfiguration):
    Appearence preferences for title and subtitle above video
  - [KinescopePreviewModel](/Documentation/KinescopePreviewModel):
    Model for displaying preview view

# Protocols

  - [KinescopeVideoQuality](/Documentation/KinescopeVideoQuality):
    Player item configutation
  - [KinescopeVideoPlayerDelegate](/Documentation/KinescopeVideoPlayerDelegate):
    Player delegate protocol
  - [KinescopeAssetDownloadable](/Documentation/KinescopeAssetDownloadable):
    Control protocol managing downloading of assets(concrete quality)
  - [KinescopeAssetDownloadableDelegate](/Documentation/KinescopeAssetDownloadableDelegate):
    Delegate protocol to listen assets download process events
  - [KinescopeAttachmentDownloadable](/Documentation/KinescopeAttachmentDownloadable):
    Control protocol managing downloading of attachments
  - [KinescopeAttachmentDownloadableDelegate](/Documentation/KinescopeAttachmentDownloadableDelegate):
    Delegate protocol to listen attachments download file process events
  - [KinescopeConfigurable](/Documentation/KinescopeConfigurable):
    Control protocol supporting connection between SDK and dashboard
  - [KinescopeEventsCenter](/Documentation/KinescopeEventsCenter):
    Interface for events center
  - [KinescopeInspectable](/Documentation/KinescopeInspectable):
    Protocol managing inspectations of dashboard content like videos, projects etc
  - [KinescopeLoggingLevel](/Documentation/KinescopeLoggingLevel):
    Interface for logging type
  - [KinescopeLogging](/Documentation/KinescopeLogging):
    Interface for logging
  - [KinescopePlayer](/Documentation/KinescopePlayer):
    Control protocol for player
  - [KinescopePlayerConfigurable](/Documentation/KinescopePlayerConfigurable):
    Control protocol for configuration of player
  - [KinescopeServicesProvider](/Documentation/KinescopeServicesProvider):
    Provider of services working with kinescope api and events
  - [KinescopeVideoDownloadable](/Documentation/KinescopeVideoDownloadable):
    Control protocol managing downloading of assets and videos
  - [KinescopeVideoDownloadableDelegate](/Documentation/KinescopeVideoDownloadableDelegate):
    Delegate protocol to listen videos download process events
  - [KinescopeActivityIndicating](/Documentation/KinescopeActivityIndicating):
    Abstraction for activity indicator used to indicate process of video downloading
  - [KinescopePreviewViewDelegate](/Documentation/KinescopePreviewViewDelegate)

# Global Typealiases

  - [KinescopeActivityIndicator](/Documentation/KinescopeActivityIndicator):
    Alias for view implementing `KinescopeActivityIndicating`
