<!-- TODO describe player and player view customisation -->

# KinescopeAssetDownloadable and AssetDownloader

KinescopeServicesProvider includes KinescopeAssetDownloadable which has out-of-box implementation - AssetDownloader. 
KinescopeAssetDownloadable provides an API to
1) download asset(concrete mp4 file)
2) control dowloading process via pause/resume/cancel(dequeue)
3) delete downloaded asset
4) get downloaded assets list and their paths
5) handle downloading events(progress, completion, error) via KinescopeAssetDownloadableDelegate
6) etc

You can get access to downloader with Kinescope.shared.assetDownloader and call methods from it.
To add your delegate use add(delegate: KinescopeAssetDownloadableDelegate) method.

KinescopeAssetDownloadable uses concrete asset id of some video for downloading and future access.  

AssetDownloader(out-of-box implementation of KinescopeAssetDownloadable) is based on URLSession for downloading files and uses documents directory on disk  for storing downloaded assets, all assets are kept in own directory "KinescopeAssets".

# KinescopeVideoDownloadable and VideoDownloader

KinescopeServicesProvider includes KinescopeVideoDownloadable which has out-of-box implementation - VideoDownloader. 
KinescopeVideoDownloadable provides an API to
1) download video(hls stream)
2) control dowloading process via pause/resume/cancel(dequeue)
3) delete downloaded video
4) get downloaded video list and their paths
5) handle downloading events(progress, completion, error) via KinescopeVideoDownloadableDelegate
6) etc

You can get access to downloader with Kinescope.shared.videoDownloader and call methods from it.
To add your delegate use add(delegate: KinescopeVideoDownloadableDelegate) method.

KinescopeVideoDownloadable uses video id and its url for downloading and future access.  

VideoDownloader(out-of-box implementation of KinescopeAssetDownloadable) is based on AVAssetDownloadURLSession for downloading and UserDefaults for storing paths to downloaded assets. 

# KinescopeAttachmentDownloadable and AttachmentDownloader

KinescopeServicesProvider includes KinescopeAttachmentDownloadable which has out-of-box implementation - AttachmentDownloader. 
KinescopeAttachmentDownloadable provides an API to
1) download attachment
2) control dowloading process via pause/resume/cancel(dequeue)
3) delete downloaded attachment
4) get downloaded attachments list and their paths to cache
5) handle downloading events(progress, completion, error) via KinescopeAttachmentDownloadableDelegate
6) clear all attachments from cache

You can get access to downloader with Kinescope.shared.attachmentDownloader and call methods from it.
To add your delegate use add(delegate: KinescopeAttachmentDownloadableDelegate) method.

KinescopeAttachmentDownloadable uses concrete attachment id of some file for downloading and future access.  

AttachmentDownloader(out-of-box implementation of KinescopeAssetDownloadable) is based on URLSession for downloading files and used documents directory on disk  for storing downloaded files, all attachments are kept in own directory "KinescopeAttachments".

# AirPlay

AirPlay lets you share video from Apple devices direct to Apple TV, speakers and popular smart TVs. SDK has out-of-box implementation of AirPlay. All you need to do is set your app’s AVAudioSession’s category, where policy should be AVAudioSession.RouteSharingPolicy.longForm.
