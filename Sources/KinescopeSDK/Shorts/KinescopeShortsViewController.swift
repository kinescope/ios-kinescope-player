import UIKit
import AVFoundation

/// Shorts chrome. `nil` keeps the default. `false` hides that control. Set this before the feed is shown.
/// Same role as Android `KinescopeUiConfig`. `KinescopeUiConfig` is the same type.
public enum KinescopeShortsUIConfig {
    public static var showLikeButton: Bool?
    public static var showDislikeButton: Bool?
    public static var showCommentButton: Bool?
    public static var showShareButton: Bool?
    /// Center button while paused. Tap on the video still pauses and resumes.
    public static var showPlayButton: Bool?
    /// Bottom scrub bar, its hit area, and the time chip.
    public static var showSeekBar: Bool?
    /// Stub image while the poster is missing. `false` leaves the page black.
    public static var showPreloadImage: Bool?

    public static var likeButtonIcon: UIImage?
    public static var dislikeButtonIcon: UIImage?
    public static var commentButtonIcon: UIImage?
    public static var shareButtonIcon: UIImage?
    public static var playButtonIcon: UIImage?
    /// Replaces the stub. Ignored when `showPreloadImage` is `false`.
    public static var preloadImage: UIImage?

    /// Side buttons, in points. `nil` is 34.
    public static var actionButtonSize: CGFloat?
    /// Center play button, in points. `nil` keeps 62×60.
    public static var playButtonSize: CGFloat?

    public static var seekBarProgressColor: UIColor?
    public static var seekBarTrackColor: UIColor?

    static var showsLike: Bool { showLikeButton != false }
    static var showsDislike: Bool { showDislikeButton != false }
    static var showsComment: Bool { showCommentButton != false }
    static var showsShare: Bool { showShareButton != false }
    static var showsPlayButton: Bool { showPlayButton != false }
    static var showsSeekBar: Bool { showSeekBar != false }
    static var showsPreloadImage: Bool { showPreloadImage != false }

    static func placeholder() -> UIImage? {
        guard showsPreloadImage else { return nil }
        return preloadImage ?? KinescopeShortsArtwork.image()
    }
}

public typealias KinescopeUiConfig = KinescopeShortsUIConfig

private let decodedPostersLock = NSLock()
private var decodedPostersStorage = Set<URL>()
private var posterWindowStorage = Set<URL>()
private func setPosterWindow(_ urls: [URL]) {
    decodedPostersLock.lock(); defer { decodedPostersLock.unlock() }
    posterWindowStorage = Set(urls)
}
private func inPosterWindow(_ url: URL) -> Bool {
    decodedPostersLock.lock(); defer { decodedPostersLock.unlock() }
    return posterWindowStorage.contains(url)
}
/// Posters already decoded for display. Touched from a background queue.
private var decodedPosters: DecodedSet { DecodedSet() }
private struct DecodedSet {
    func contains(_ url: URL) -> Bool {
        decodedPostersLock.lock(); defer { decodedPostersLock.unlock() }
        return decodedPostersStorage.contains(url)
    }
    func insert(_ url: URL) {
        decodedPostersLock.lock(); defer { decodedPostersLock.unlock() }
        decodedPostersStorage.insert(url)
    }
}

/// Vertical feed. Poster stays until playback starts, side actions sit on the right, and the bottom bar seeks.
public final class KinescopeShortsViewController: UIViewController, KinescopeVideoPlayerDelegate {

    private var videos: [KinescopeLibraryVideo] = []
    private let collectionView: UICollectionView
    private var currentPlayer: KinescopeVideoPlayer?
    private weak var currentHost: KinescopePlayerView?
    private var currentIndex: Int?
    private var appliedPageSize: CGSize = .zero
    private let posters = NSCache<NSURL, UIImage>()
    private var playbackActive = false
    /// The viewer pressed pause. A seek or a player handoff also reports paused and must not stop the clip.
    private var userPaused = false
    private var resumeAttempt = 0
    private var coverTime: TimeInterval?
    private var scrubWasPaused = false
    private var screenReady = false
    /// Set only from viewDidAppear. Preparing the feed must not start playback.
    private var didAppear = false
    private var catalogReady = false
    private var feedPresented = false
    private var preloads: [Int: ShortsPreload] = [:]
    /// Players that left the window. Torn down only after the feed has been still, never during a swipe.
    private var doomed: [ShortsPreload] = []
    /// Playing when the app was minimized, so shorts resume on return.
    private var resumeWhenActive = false
    /// End of the clip seeks back to the start. Ignores the pause that the finished item posts.
    private var replaying = false
    /// Page under the finger. Once the scroll leaves it, that player pauses.
    private var dragOrigin: Int?
    /// True from the start of a drag until the page has stopped. Player teardown waits this out.
    private var scrollBusy = false
    /// Page the finger is heading to. Its video starts before the glide finishes.
    private var landingIndex: Int?
    /// A paused status during the scroll must not start the clip again.
    private var scrollInterrupted = false
    private var pausedForScroll = false
    private var resumeAfterScroll = false
    /// The page just left stays paused on its frame until the scroll ends, so a swipe back starts at once.
    private var retiredPlayer: KinescopeVideoPlayer?
    private var retiredIndex: Int?
    private weak var retiredHost: KinescopePlayerView?
    private let openingStub = UIImageView(image: KinescopeShortsUIConfig.placeholder())
    private let projectId: String?
    private let folderId: String?
    private let perPage: Int

    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask { .portrait }

    /// Vertical feed. `projectId` and `folderId` match `KinescopeDashboard.videos`: nil is no filter.
    public init(projectId: String? = nil, folderId: String? = nil, perPage: Int = 100) {
        self.projectId = projectId
        self.folderId = folderId
        self.perPage = perPage
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(nibName: nil, bundle: nil)
    }

    public required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        openingStub.image = KinescopeShortsUIConfig.placeholder()
        collectionView.backgroundColor = .black
        collectionView.isPagingEnabled = true
        collectionView.alwaysBounceVertical = true
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(ShortsPageCell.self, forCellWithReuseIdentifier: ShortsPageCell.reuseID)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        let close = UIButton(type: .system)
        close.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        close.tintColor = .white
        close.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        close.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(close)
        NSLayoutConstraint.activate([
            close.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            close.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            close.widthAnchor.constraint(equalToConstant: 40),
            close.heightAnchor.constraint(equalToConstant: 40)
        ])
        openingStub.contentMode = .scaleAspectFill
        openingStub.clipsToBounds = true
        openingStub.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(openingStub)
        NSLayoutConstraint.activate([
            openingStub.topAnchor.constraint(equalTo: view.topAnchor),
            openingStub.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            openingStub.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            openingStub.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        view.bringSubviewToFront(close)
        NotificationCenter.default.addObserver(self, selector: #selector(appWillResign),
                                               name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive),
                                               name: UIApplication.didBecomeActiveNotification, object: nil)
        KinescopeDashboard.videos(perPage: perPage,
                                  projectId: projectId,
                                  folderId: folderId) { [weak self] result in
            guard let self, case .success(let videos) = result else { return }
            self.videos = videos
            self.catalogReady = true
            self.decodePosters(around: 0)
            self.prefetchPosters()
            self.presentFeedIfNeeded()
        }
    }

    @objc private func appWillResign() {
        resumeWhenActive = playbackActive
    }

    @objc private func appDidBecomeActive() {
        guard resumeWhenActive, view.window != nil else { return }
        resumeWhenActive = false
        currentPlayer?.play()
        playbackActive = true
        currentCell()?.setPlayback(playing: true)
        currentCell()?.hidePoster(animated: false)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        didAppear = true
        screenReady = true
        presentFeedIfNeeded()
        beginPlaybackIfOnScreen()
    }

    /// Lays the feed out before the screen is shown. The menu calls this while it is idle.
    public func prepareForOpen() {
        loadViewIfNeeded()
        view.frame = UIScreen.main.bounds
        view.layoutIfNeeded()
        screenReady = true
        presentFeedIfNeeded()
    }

    private func prefetchPosters() {
        posters.countLimit = 200
        for video in videos {
            guard let url = video.posterURL, posters.object(forKey: url as NSURL) == nil else { continue }
            URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
                guard let self, let data, var image = UIImage(data: data) else { return }
                if inPosterWindow(url), let ready = image.preparingForDisplay() {
                    image = ready
                    DecodedSet().insert(url)
                }
                self.posters.setObject(image, forKey: url as NSURL)
                DispatchQueue.main.async {
                    for case let cell as ShortsPageCell in self.collectionView.visibleCells {
                        cell.useCachedPoster(image, url: url)
                    }
                }
            }.resume()
        }
    }

    /// Posters arrive compressed and are decoded on first draw, which lands on the main thread mid-swipe.
    /// The pages around the current one are decoded here, away from it.
    private func decodePosters(around index: Int) {
        let urls = ((index - 1)...(index + 4)).compactMap { i -> URL? in
            videos.indices.contains(i) ? videos[i].posterURL : nil
        }
        setPosterWindow(urls)
        let cache = posters
        DispatchQueue.global(qos: .utility).async {
            for url in urls {
                guard let image = cache.object(forKey: url as NSURL), !decodedPosters.contains(url) else { continue }
                if let ready = image.preparingForDisplay() {
                    cache.setObject(ready, forKey: url as NSURL)
                    decodedPosters.insert(url)
                }
            }
        }
    }

    private func presentFeedIfNeeded() {
        guard screenReady, catalogReady, !feedPresented else { return }
        feedPresented = true
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.collectionView.reloadData()
            self.collectionView.layoutIfNeeded()
            self.prepareReusePool()
            self.decodePosters(around: 0)
            self.openingStub.isHidden = true
            self.beginPlaybackIfOnScreen()
        }
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let size = collectionView.bounds.size
        guard size.width > 0, size.height > 0, size != appliedPageSize else { return }
        appliedPageSize = size
        (collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.itemSize = size
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingFromParent {
            navigationController?.setNavigationBarHidden(false, animated: false)
            releasePlayer()
            releasePreloads()
        }
    }

    /// Playback starts only on the visible screen. An offscreen prepare must not play audio over the menu.
    private func beginPlaybackIfOnScreen() {
        guard didAppear, feedPresented, currentPlayer == nil else { return }
        settle()
    }

    private func settle() {
        guard !collectionView.isDragging, !collectionView.isDecelerating else { return }
        discardRetired()
        scrollInterrupted = false
        preloads.values.forEach { $0.resumePrepare() }
        let height = max(collectionView.bounds.height, 1)
        let index = Int(round(collectionView.contentOffset.y / height))
        guard videos.indices.contains(index) else { return }
        scrollBusy = false
        if currentIndex != index {
            play(videos[index].id, at: index)
        } else if pausedForScroll, resumeAfterScroll, !userPaused {
            currentPlayer?.setVolume(1)
            currentPlayer?.play()
            playbackActive = true
            currentCell()?.setPlayback(playing: true)
            scheduleWarm(around: index)
        } else {
            scheduleWarm(around: index)
        }
        pausedForScroll = false
        landingIndex = nil
    }

    /// The playhead is on the last fraction of the clip, where the layer has no picture.
    private static func isAtEnd(_ player: KinescopeVideoPlayer) -> Bool {
        guard let duration = player.duration, duration > 0 else { return false }
        return player.currentTime >= duration - 0.2
    }

    private func play(_ videoId: String, at index: Int, cell known: ShortsPageCell? = nil) {
        guard currentIndex != index else {
            landingIndex = nil
            return
        }
        let cell = known ?? (collectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? ShortsPageCell)
        guard let cell else { return }

        let player: KinescopeVideoPlayer
        let ready: Bool
        if retiredIndex == index, let retired = retiredPlayer {
            let host = retiredHost
            retiredPlayer = nil
            retiredIndex = nil
            retiredHost = nil
            if host !== cell.playerView {
                if let host {
                    retired.detach(view: host)
                }
                retired.attach(view: cell.playerView)
            }
            player = retired
            ready = !Self.isAtEnd(retired)
        } else if let slot = preloads.removeValue(forKey: index) {
            // Already on this cell with a picture: the swipe can show it at once, the way Android does.
            ready = slot.showsFrame && slot.isPlaced(on: cell.playerView)
            player = slot.takeOver(on: cell.playerView)
        } else {
            ready = false
            player = KinescopeVideoPlayer(config: .init(videoId: videoId))
            player.setMaximumVideoHeight(480)
            player.attach(view: cell.playerView)
        }

        retireCurrent()
        scrollInterrupted = false
        player.setDelegate(delegate: self)
        player.setVolume(1)
        playbackActive = true
        userPaused = false
        resumeAttempt = 0
        replaying = false
        // A frame that is already on this cell shows immediately. Otherwise the poster stays
        // until playback moves, because a freshly attached layer is black for the first moment.
        if ready {
            cell.hidePoster(animated: false)
        } else {
            cell.showPoster()
        }
        if Self.isAtEnd(player) {
            player.seek(to: 0)
        }
        currentPlayer = player
        currentHost = cell.playerView
        currentIndex = index
        landingIndex = nil
        player.revealPictureOnPlay()
        player.play()
        coverTime = ready ? nil : 0
        bind(cell, videoId: videoId)
        cell.setPlayback(playing: true)
        keepRetiredNeighbor()
        scheduleWarm(around: index)
    }

    private func neighborIndexes(around index: Int) -> [Int] {
        // +3 is the fourth video. It has to exist before the swipe from the third one.
        [index - 1, index + 1, index + 2, index + 3].filter { videos.indices.contains($0) }
    }

    /// Creates the first pages while the opening cover is up, so scrolling to the fourth one reuses a cell.
    private func prepareReusePool() {
        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        let page = collectionView.bounds.height
        guard page > 1, videos.count > 3 else { return }
        let full = layout.itemSize
        layout.itemSize = CGSize(width: collectionView.bounds.width, height: page / 6)
        collectionView.collectionViewLayout.invalidateLayout()
        collectionView.layoutIfNeeded()
        layout.itemSize = full.width > 1 ? full : CGSize(width: collectionView.bounds.width, height: page)
        collectionView.collectionViewLayout.invalidateLayout()
        collectionView.layoutIfNeeded()
    }

    /// Neighbours are prepared one at a time, and only once the page has stopped.
    /// Building several players inside the scroll callback is what freezes the feed.
    private func scheduleWarm(around index: Int) {
        DispatchQueue.main.async { [weak self] in
            guard let self, !self.scrollBusy, self.currentIndex == index else { return }
            guard !self.collectionView.isDragging, !self.collectionView.isDecelerating else { return }
            self.decodePosters(around: index)
            self.warm(around: index)
        }
    }

    /// Like the Android pool: neighbours buffer while the current page plays, and a ready one
    /// already shows its first frame so the next page does not open on the poster.
    private func warm(around index: Int) {
        let wanted = neighborIndexes(around: index)
        for key in Array(preloads.keys) where !wanted.contains(key) {
            if let slot = preloads.removeValue(forKey: key) {
                doomed.append(slot)
            }
        }
        scheduleDoom()
        guard let next = wanted.first(where: { preloads[$0] == nil }) else {
            for item in wanted {
                if let slot = preloads[item] {
                    reveal(slot)
                }
            }
            return
        }
        let slot = ShortsPreload(index: next, videoId: videos[next].id)
        slot.onPrimed = { [weak self, weak slot] in
            guard let self, let slot else { return }
            self.reveal(slot)
        }
        view.insertSubview(slot.host, at: 0)
        preloads[next] = slot
        reveal(slot)
        if wanted.contains(where: { preloads[$0] == nil }) {
            DispatchQueue.main.async { [weak self] in
                self?.scheduleWarm(around: index)
            }
        }
    }

    /// Puts a prepared player under the poster. The poster stays until that page starts playing.
    private func reveal(_ slot: ShortsPreload) {
        guard slot.showsFrame,
              let cell = collectionView.cellForItem(at: IndexPath(item: slot.index, section: 0)) as? ShortsPageCell,
              currentIndex != slot.index else { return }
        slot.place(on: cell.playerView)
    }

    /// `replaceCurrentItem` stalls the main thread. It runs only once the finger and the glide have stopped.
    private func scheduleDoom() {
        guard !doomed.isEmpty else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak self] in
            guard let self else { return }
            let busy = self.scrollBusy || self.collectionView.isDragging || self.collectionView.isDecelerating
            guard !busy, let slot = self.doomed.first else {
                if !self.doomed.isEmpty { self.scheduleDoom() }
                return
            }
            self.doomed.removeFirst()
            slot.release()
            if !self.doomed.isEmpty { self.scheduleDoom() }
        }
    }

    private func releasePreloads() {
        (Array(preloads.values) + doomed).forEach { $0.release() }
        preloads.removeAll()
        doomed.removeAll()
    }

    /// The page being left keeps its picture, but it no longer plays.
    private func retireCurrent() {
        discardRetired()
        guard let player = currentPlayer else { return }
        player.setDelegate(delegate: idleShortsDelegate)
        player.setVolume(0)
        player.pause()
        retiredPlayer = player
        retiredIndex = currentIndex
        retiredHost = currentHost
        currentPlayer = nil
        currentHost = nil
        currentIndex = nil
        playbackActive = false
    }

    /// A neighbour that already has a picture stays in the pool, so coming back does not open on the poster.
    private func keepRetiredNeighbor() {
        guard let index = retiredIndex,
              let current = currentIndex,
              neighborIndexes(around: current).contains(index),
              preloads[index] == nil,
              let player = retiredPlayer,
              let host = retiredHost else { return }
        retiredPlayer = nil
        retiredIndex = nil
        retiredHost = nil
        let slot = ShortsPreload(keeping: player, index: index, placedOn: host)
        preloads[index] = slot
        guard !slot.showsFrame,
              let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? ShortsPageCell else { return }
        cell.showPoster()
    }

    private func discardRetired() {
        guard let player = retiredPlayer else { return }
        let host = retiredHost
        let index = retiredIndex
        retiredPlayer = nil
        retiredHost = nil
        retiredIndex = nil
        if let host {
            player.detach(view: host)
        }
        if let index,
           let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? ShortsPageCell,
           host == nil || cell.playerView === host {
            cell.showPoster()
            cell.resetPlayback()
            cell.onShare = nil
            cell.onToggle = nil
            cell.onScrubBegan = nil
            cell.onScrubEnded = nil
        }
        player.setDelegate(delegate: idleShortsDelegate)
        player.pause()
        player.relinquish()
    }

    private func releasePlayer() {
        retireCurrent()
        discardRetired()
    }

    private func bind(_ cell: ShortsPageCell, videoId: String) {
        cell.onShare = { [weak self] in
            let activity = UIActivityViewController(activityItems: ["https://kinescope.io/\(videoId)"],
                                                    applicationActivities: nil)
            self?.present(activity, animated: true)
        }
        cell.onToggle = { [weak self] in
            guard let self else { return }
            if self.userPaused {
                self.userPaused = false
                self.playbackActive = true
                self.currentPlayer?.play()
            } else {
                self.userPaused = true
                self.playbackActive = false
                self.currentPlayer?.pause()
            }
        }
        cell.durationProvider = { [weak self] in
            self?.currentPlayer?.duration ?? 0
        }
        cell.onScrubBegan = { [weak self] in
            guard let self else { return }
            self.scrubWasPaused = !self.playbackActive
            if self.scrubWasPaused {
                self.currentPlayer?.play()
            }
        }
        cell.onScrubEnded = { [weak self] fraction in
            guard let self else { return true }
            if let fraction, let duration = self.currentPlayer?.duration, duration > 0 {
                self.currentPlayer?.seek(to: duration * TimeInterval(fraction))
            }
            if self.scrubWasPaused {
                self.currentPlayer?.pause()
                self.playbackActive = false
                return false
            }
            return true
        }
    }

    private func currentCell() -> ShortsPageCell? {
        guard let index = currentIndex else { return nil }
        return collectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? ShortsPageCell
    }

    public func player(changedTimeControlStatusTo status: AVPlayer.TimeControlStatus) {
        guard currentPlayer != nil, !scrollInterrupted else { return }
        if status == .paused, !userPaused {
            playbackActive = true
            currentCell()?.setPlayback(playing: true)
            guard resumeAttempt < 2, currentPlayer != nil else { return }
            resumeAttempt += 1
            DispatchQueue.main.async { [weak self] in
                guard let self, !self.userPaused, let player = self.currentPlayer else { return }
                if Self.isAtEnd(player) {
                    self.replayIfNeeded()
                } else {
                    player.play()
                }
            }
            return
        }
        if status == .playing {
            resumeAttempt = 0
            replaying = false
            playbackActive = true
            if let player = currentPlayer, !Self.isAtEnd(player) {
                currentCell()?.hidePoster(animated: false)
                openingStub.isHidden = true
                coverTime = nil
            }
        }
        currentCell()?.setPlayback(playing: playbackActive && !userPaused)
    }

    public func player(playbackPositionMovedTo time: TimeInterval) {
        if replaying, time < 0.3 {
            replaying = false
        }
        if playbackActive, !userPaused, let player = currentPlayer, !Self.isAtEnd(player), time > 0.05 {
            currentCell()?.hidePoster(animated: false)
            openingStub.isHidden = true
            coverTime = nil
        }
        guard let duration = currentPlayer?.duration, duration > 0,
              !collectionView.isDragging else { return }
        currentCell()?.setProgress(CGFloat(time / duration), duration: duration)
    }

    public func playerDidFinishPlaying() {
        replayIfNeeded()
    }

    /// Finished clip starts again from the beginning. A second end event during the seek is ignored.
    @discardableResult
    private func replayIfNeeded() -> Bool {
        guard let player = currentPlayer, !replaying else { return replaying }
        guard let duration = player.duration, duration > 0, player.currentTime >= duration - 0.35 else {
            return false
        }
        replaying = true
        playbackActive = true
        player.seek(to: 0)
        currentCell()?.setPlayback(playing: true)
        return true
    }

    @objc private func closeTapped() {
        navigationController?.popViewController(animated: true)
    }
}

extension KinescopeShortsViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        videos.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ShortsPageCell.reuseID, for: indexPath) as! ShortsPageCell
        let video = videos[indexPath.item]
        if indexPath.item != currentIndex, let currentHost, cell.playerView === currentHost {
            currentPlayer?.detach(view: cell.playerView)
            self.currentHost = nil
        }
        if indexPath.item != retiredIndex, let retiredHost, cell.playerView === retiredHost {
            retiredPlayer?.detach(view: cell.playerView)
            self.retiredHost = nil
        }
        for slot in preloads.values where slot.isPlaced(on: cell.playerView) && slot.index != indexPath.item {
            slot.returnToHost()
        }
        let playing = indexPath.item == currentIndex && currentPlayer != nil
        // The page being swiped to shows its poster until a player is ready. Only the current page skips the reset.
        cell.apply(video, posters: posters, playing: playing)
        if playing {
            // A reload or a reused cell hands this page a view the player is not on. Without this the audio plays on a black page.
            if let player = currentPlayer, currentHost !== cell.playerView {
                if let old = currentHost {
                    player.detach(view: old)
                }
                player.attach(view: cell.playerView)
                currentHost = cell.playerView
                if player.isPlaying, !Self.isAtEnd(player) {
                    cell.hidePoster(animated: false)
                } else {
                    cell.showPoster()
                }
            }
            bind(cell, videoId: video.id)
            cell.setPlayback(playing: playbackActive && !userPaused)
        } else if let slot = preloads[indexPath.item], slot.showsFrame {
            slot.place(on: cell.playerView)
        }
        if indexPath.item == landingIndex, currentIndex != indexPath.item, preparedPlayer(at: indexPath.item) {
            play(video.id, at: indexPath.item, cell: cell)
        }
        return cell
    }

    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        scrollBusy = true
        dragOrigin = currentIndex
        pausedForScroll = false
        preloads.values.forEach { $0.pausePrepare() }
    }

    /// The page under the finger stops as soon as the scroll actually leaves it.
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let origin = dragOrigin, origin == currentIndex, !pausedForScroll else { return }
        guard scrollView.isDragging || scrollView.isDecelerating else { return }
        let height = max(scrollView.bounds.height, 1)
        guard abs(scrollView.contentOffset.y / height - CGFloat(origin)) > 0.08 else { return }
        resumeAfterScroll = playbackActive && !userPaused
        pausedForScroll = true
        scrollInterrupted = true
        currentPlayer?.setVolume(0)
        currentPlayer?.pause()
    }

    /// Playback of the page being opened starts here, while the collection is still gliding.
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView,
                                   withVelocity velocity: CGPoint,
                                   targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let height = max(collectionView.bounds.height, 1)
        let index = Int(round(targetContentOffset.pointee.y / height))
        dragOrigin = nil
        guard videos.indices.contains(index) else { return }
        if index == currentIndex {
            landingIndex = nil
            scrollInterrupted = false
            if pausedForScroll, resumeAfterScroll, !userPaused {
                currentPlayer?.setVolume(1)
                currentPlayer?.play()
                playbackActive = true
                currentCell()?.setPlayback(playing: true)
            }
            pausedForScroll = false
            return
        }
        if !pausedForScroll {
            resumeAfterScroll = playbackActive && !userPaused
            pausedForScroll = true
        }
        scrollInterrupted = true
        currentPlayer?.setVolume(0)
        currentPlayer?.pause()
        landingIndex = index
        // A player that is already buffered starts with the swipe. Building a new one here is what
        // makes the first launch stutter on the way from the third video to the fourth.
        if preparedPlayer(at: index) {
            play(videos[index].id, at: index)
        }
    }

    /// True when the page can start from a player that already exists. Creating one waits until the swipe ends.
    private func preparedPlayer(at index: Int) -> Bool {
        preloads[index] != nil || retiredIndex == index
    }

    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        settle()
    }

    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            settle()
        }
    }
}

private final class ShortsPageCell: UICollectionViewCell, UIGestureRecognizerDelegate {
    static let reuseID = "ShortsPageCell"
    let playerView = KinescopePlayerView()
    var onShare: (() -> Void)?
    var onToggle: (() -> Void)?
    var onScrubBegan: (() -> Void)?
    var onScrubEnded: ((CGFloat?) -> Bool)?
    var durationProvider: (() -> TimeInterval)?

    private let posterView = UIImageView()
    private let titleLabel = UILabel()
    private let summaryLabel = UILabel()
    private let textStack = UIStackView()
    private let actions = UIStackView()
    private let likeButton = UIButton(type: .system)
    private let dislikeButton = UIButton(type: .system)
    private let commentButton = UIButton(type: .system)
    private let shareButton = UIButton(type: .system)
    private let playButton = UIButton(type: .system)
    private let hitArea = UIView()
    private let seekTrack = UIView()
    private let seekFill = UIView()
    private let timeBubble = UIView()
    private let timeLabel = UILabel()
    private var fillWidth: NSLayoutConstraint!
    private var timeCenter: NSLayoutConstraint!
    private var posterTask: URLSessionDataTask?
    private var fraction: CGFloat = 0
    private var anchorFraction: CGFloat = 0
    private var mediaDuration: TimeInterval = 0
    private var dragConfirmed = false
    private var chromeHidden = false
    private var isPlaying = false
    private var hasStarted = false
    private var summaryVisible = false
    private var playbackErrorVisible = false
    private var titleExpanded = false
    private var summaryExpanded = false
    private let scrubPan = UIPanGestureRecognizer()
    private let videoTap = UITapGestureRecognizer()
    private let titleTap = UITapGestureRecognizer()
    private let summaryTap = UITapGestureRecognizer()

    private var chrome: [UIView] {
        var views: [UIView] = [titleLabel]
        if KinescopeShortsUIConfig.showsLike { views.append(likeButton) }
        if KinescopeShortsUIConfig.showsDislike { views.append(dislikeButton) }
        if KinescopeShortsUIConfig.showsComment { views.append(commentButton) }
        if KinescopeShortsUIConfig.showsShare { views.append(shareButton) }
        if summaryVisible {
            views.append(summaryLabel)
        }
        return views
    }
    private var actionSizes: [ObjectIdentifier: (NSLayoutConstraint, NSLayoutConstraint)] = [:]
    private var playWidth: NSLayoutConstraint!
    private var playHeight: NSLayoutConstraint!

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .black
        contentView.backgroundColor = .black
        playerView.setLayout(with: .builder()
            .setGravity(.resizeAspect)
            .setOverlay(nil)
            .setControlPanel(nil)
            .setShadowOverlay(nil)
            .setPictureInPicture(false)
            .build())
        playerView.onPlaybackErrorVisibility = { [weak self] visible in
            self?.playbackErrorVisible = visible
            self?.applyChromeVisibility()
        }
        playerView.previewView.isHidden = true
        playerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(playerView)

        posterView.image = KinescopeShortsUIConfig.placeholder()
        posterView.contentMode = .scaleAspectFill
        posterView.clipsToBounds = true
        posterView.backgroundColor = .black
        posterView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(posterView)

        hitArea.backgroundColor = .clear
        hitArea.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(hitArea)
        scrubPan.addTarget(self, action: #selector(scrubbed(_:)))
        scrubPan.delegate = self
        hitArea.addGestureRecognizer(scrubPan)

        seekTrack.backgroundColor = UIColor.white.withAlphaComponent(82.0 / 255.0)
        seekTrack.layer.cornerRadius = 2
        seekTrack.clipsToBounds = true
        seekTrack.isHidden = true
        seekTrack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(seekTrack)
        seekFill.backgroundColor = UIColor(red: 97.0 / 255.0, green: 97.0 / 255.0, blue: 252.0 / 255.0, alpha: 1)
        seekFill.layer.cornerRadius = 2
        seekFill.translatesAutoresizingMaskIntoConstraints = false
        seekTrack.addSubview(seekFill)
        fillWidth = seekFill.widthAnchor.constraint(equalToConstant: 0)

        timeBubble.backgroundColor = UIColor(red: 17.0 / 255.0, green: 17.0 / 255.0, blue: 17.0 / 255.0, alpha: 0.8)
        timeBubble.layer.cornerRadius = 4
        timeBubble.layer.zPosition = 20
        timeBubble.isHidden = true
        timeBubble.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.font = .systemFont(ofSize: 18)
        timeLabel.textColor = .white
        timeLabel.text = "0:00"
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeBubble.addSubview(timeLabel)
        timeCenter = timeBubble.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)

        style(titleLabel, size: 18, weight: .medium)
        style(summaryLabel, size: 14, weight: .regular)
        titleLabel.isUserInteractionEnabled = true
        summaryLabel.isUserInteractionEnabled = true
        titleTap.addTarget(self, action: #selector(titleTapped))
        summaryTap.addTarget(self, action: #selector(summaryTapped))
        titleLabel.addGestureRecognizer(titleTap)
        summaryLabel.addGestureRecognizer(summaryTap)
        textStack.addArrangedSubview(titleLabel)
        textStack.addArrangedSubview(summaryLabel)
        textStack.axis = .vertical
        textStack.spacing = 4
        textStack.isUserInteractionEnabled = true
        textStack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(textStack)

        actions.axis = .vertical
        actions.spacing = 18
        actions.alignment = .center
        actions.translatesAutoresizingMaskIntoConstraints = false
        configure(likeButton, asset: "shortsLike")
        configure(dislikeButton, asset: "shortsDislike")
        configure(commentButton, asset: "shortsComment")
        configure(shareButton, asset: "shortsShare")
        shareButton.addTarget(self, action: #selector(shareTapped), for: .touchUpInside)
        [likeButton, dislikeButton, commentButton, shareButton].forEach { actions.addArrangedSubview($0) }
        contentView.addSubview(actions)

        playButton.setImage(Self.icon("shortsPlay"), for: .normal)
        playButton.tintColor = .white
        playButton.alpha = 0.3
        playButton.isHidden = true
        playButton.contentHorizontalAlignment = .fill
        playButton.contentVerticalAlignment = .fill
        playButton.imageView?.contentMode = .scaleAspectFit
        playButton.addTarget(self, action: #selector(toggleTapped), for: .touchUpInside)
        playButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(playButton)
        contentView.addSubview(timeBubble)

        videoTap.addTarget(self, action: #selector(toggleTapped))
        videoTap.delegate = self
        contentView.addGestureRecognizer(videoTap)

        NSLayoutConstraint.activate([
            playerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            playerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            playerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            playerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            posterView.topAnchor.constraint(equalTo: contentView.topAnchor),
            posterView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            posterView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            posterView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            hitArea.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            hitArea.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            hitArea.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            hitArea.heightAnchor.constraint(equalToConstant: 140),
            seekTrack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            seekTrack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            seekTrack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -56),
            seekTrack.heightAnchor.constraint(equalToConstant: 4),
            seekFill.leadingAnchor.constraint(equalTo: seekTrack.leadingAnchor),
            seekFill.topAnchor.constraint(equalTo: seekTrack.topAnchor),
            seekFill.bottomAnchor.constraint(equalTo: seekTrack.bottomAnchor),
            fillWidth,
            timeCenter,
            timeBubble.bottomAnchor.constraint(equalTo: seekTrack.topAnchor, constant: -12),
            timeLabel.leadingAnchor.constraint(equalTo: timeBubble.leadingAnchor, constant: 10),
            timeLabel.trailingAnchor.constraint(equalTo: timeBubble.trailingAnchor, constant: -10),
            timeLabel.topAnchor.constraint(equalTo: timeBubble.topAnchor, constant: 5),
            timeLabel.bottomAnchor.constraint(equalTo: timeBubble.bottomAnchor, constant: -5),
            actions.widthAnchor.constraint(equalToConstant: 44),
            actions.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            actions.bottomAnchor.constraint(equalTo: seekTrack.topAnchor, constant: -28),
            textStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            textStack.trailingAnchor.constraint(equalTo: actions.leadingAnchor, constant: -16),
            textStack.bottomAnchor.constraint(equalTo: seekTrack.topAnchor, constant: -16),
            playButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            playButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        playWidth = playButton.widthAnchor.constraint(equalToConstant: 62)
        playHeight = playButton.heightAnchor.constraint(equalToConstant: 60)
        NSLayoutConstraint.activate([playWidth, playHeight])
        applyAppearance()
    }

    public required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func prepareForReuse() {
        super.prepareForReuse()
        posterTask?.cancel()
        posterTask = nil
        onShare = nil
        onToggle = nil
        onScrubBegan = nil
        onScrubEnded = nil
        durationProvider = nil
        fraction = 0
        mediaDuration = 0
        dragConfirmed = false
        chromeHidden = false
        collapseText(animated: false)
        seekTrack.transform = .identity
        timeBubble.isHidden = true
        chrome.forEach {
            $0.isHidden = false
            $0.alpha = 1
        }
        resetPlayback()
        showPoster()
        applyAppearance()
    }

    func apply(_ video: KinescopeLibraryVideo, posters: NSCache<NSURL, UIImage>, playing: Bool) {
        collapseText(animated: false)
        titleLabel.text = video.title
        summaryLabel.text = video.summary
        if let duration = video.duration, duration > 0 {
            mediaDuration = duration
        }
        summaryVisible = video.summary != nil
        summaryLabel.isHidden = !summaryVisible
        if playing {
            return
        }
        fraction = 0
        showPoster()
        resetPlayback()
        posterTask?.cancel()
        guard let url = video.posterURL else {
            posterView.image = KinescopeShortsUIConfig.placeholder()
            posterView.accessibilityIdentifier = nil
            return
        }
        if posterView.accessibilityIdentifier != url.absoluteString {
            posterView.image = posters.object(forKey: url as NSURL) ?? KinescopeShortsUIConfig.placeholder()
            posterView.accessibilityIdentifier = url.absoluteString
        }
        if let image = posters.object(forKey: url as NSURL) {
            posterView.image = image
            return
        }
        posterTask = URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let data, let raw = UIImage(data: data) else { return }
            // Decoded here, so the first draw on screen does not spend a frame on it.
            let image = raw.preparingForDisplay() ?? raw
            posters.setObject(image, forKey: url as NSURL)
            DispatchQueue.main.async {
                guard self?.posterView.accessibilityIdentifier == url.absoluteString else { return }
                self?.posterView.image = image
            }
        }
        posterTask?.resume()
    }

    func showPoster() {
        posterView.alpha = 1
        posterView.isHidden = false
    }

    func useCachedPoster(_ image: UIImage, url: URL) {
        guard posterView.accessibilityIdentifier == url.absoluteString else { return }
        posterView.image = image
    }

    func hidePoster(animated: Bool = true) {
        guard !posterView.isHidden || posterView.alpha > 0 else { return }
        guard animated else {
            posterView.layer.removeAllAnimations()
            posterView.alpha = 0
            posterView.isHidden = true
            return
        }
        UIView.animate(withDuration: 0.2, animations: {
            self.posterView.alpha = 0
        }, completion: { finished in
            guard finished, self.posterView.alpha == 0 else { return }
            self.posterView.isHidden = true
        })
    }

    func resetPlayback() {
        isPlaying = false
        hasStarted = false
        playbackErrorVisible = false
        applyChromeVisibility()
    }

    func setPlayback(playing: Bool) {
        hasStarted = true
        isPlaying = playing
        guard !dragConfirmed else { return }
        applyChromeVisibility()
    }

    func setProgress(_ value: CGFloat, duration: TimeInterval) {
        mediaDuration = duration
        guard !dragConfirmed else { return }
        fraction = min(1, max(0, value))
        setNeedsLayout()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let width = seekTrack.bounds.width * fraction
        if abs(fillWidth.constant - width) > 0.5 {
            fillWidth.constant = width
        }
        guard dragConfirmed, contentView.bounds.width > 0 else { return }
        let bubbleWidth = max(timeLabel.intrinsicContentSize.width + 20, 52)
        let half = bubbleWidth / 2
        var center = seekTrack.frame.minX + seekTrack.bounds.width * fraction
        let limit = contentView.bounds.width
        center = min(max(8 + half, center), max(8 + half, limit - 8 - half))
        let constant = center - limit / 2
        if abs(timeCenter.constant - constant) > 0.5 {
            timeCenter.constant = constant
        }
    }

    private func applyChromeVisibility() {
        let showPaused = hasStarted && !isPlaying && !dragConfirmed && !playbackErrorVisible
        playButton.isHidden = !showPaused || !KinescopeShortsUIConfig.showsPlayButton
        seekTrack.isHidden = !KinescopeShortsUIConfig.showsSeekBar || !(showPaused || dragConfirmed)
    }

    /// One line with an ellipsis. A tap opens the rest, up to the Android limits, then a second tap closes it.
    @objc private func titleTapped() {
        toggleText(titleLabel, expanded: &titleExpanded, limit: 5)
    }

    @objc private func summaryTapped() {
        toggleText(summaryLabel, expanded: &summaryExpanded, limit: 10)
    }

    private func toggleText(_ label: UILabel, expanded: inout Bool, limit: Int) {
        let truncated = Self.isTruncated(label, width: measureWidth(for: label))
        guard expanded || truncated else { return }
        expanded.toggle()
        label.preferredMaxLayoutWidth = measureWidth(for: label)
        label.numberOfLines = expanded ? limit : 1
        label.lineBreakMode = expanded ? .byWordWrapping : .byTruncatingTail
        UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseOut, .allowUserInteraction]) {
            self.contentView.layoutIfNeeded()
        }
    }

    private func collapseText(animated: Bool) {
        titleExpanded = false
        summaryExpanded = false
        titleLabel.numberOfLines = 1
        summaryLabel.numberOfLines = 1
        titleLabel.lineBreakMode = .byTruncatingTail
        summaryLabel.lineBreakMode = .byTruncatingTail
        guard animated else { return }
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut) {
            self.contentView.layoutIfNeeded()
        }
    }

    private func measureWidth(for label: UILabel) -> CGFloat {
        if label.bounds.width > 1 {
            return label.bounds.width
        }
        return max(0, contentView.bounds.width - 16 - 44 - 16 - 16)
    }

    private static func isTruncated(_ label: UILabel, width: CGFloat) -> Bool {
        guard let text = label.text?.trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty else {
            return false
        }
        guard width > 1, let font = label.font else { return false }
        let full = (text as NSString).boundingRect(
            with: CGSize(width: width, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: [.font: font],
            context: nil
        )
        return full.height > font.lineHeight * 1.15
    }

    private func style(_ label: UILabel, size: CGFloat, weight: UIFont.Weight) {
        label.textColor = .white
        label.font = .systemFont(ofSize: size, weight: weight)
        label.numberOfLines = 1
        label.shadowColor = UIColor.black.withAlphaComponent(0.64)
        label.shadowOffset = CGSize(width: 0.5, height: 0.5)
    }

    private func configure(_ button: UIButton, asset: String) {
        button.tintColor = .white
        button.contentHorizontalAlignment = .fill
        button.contentVerticalAlignment = .fill
        button.imageView?.contentMode = .scaleAspectFit
        button.translatesAutoresizingMaskIntoConstraints = false
        let width = button.widthAnchor.constraint(equalToConstant: 34)
        let height = button.heightAnchor.constraint(equalToConstant: 34)
        NSLayoutConstraint.activate([width, height])
        actionSizes[ObjectIdentifier(button)] = (width, height)
        button.setImage(Self.icon(asset), for: .normal)
    }

    private func applyAppearance() {
        let ui = KinescopeShortsUIConfig.self
        apply(likeButton, shown: ui.showsLike, icon: ui.likeButtonIcon, asset: "shortsLike")
        apply(dislikeButton, shown: ui.showsDislike, icon: ui.dislikeButtonIcon, asset: "shortsDislike")
        apply(commentButton, shown: ui.showsComment, icon: ui.commentButtonIcon, asset: "shortsComment")
        apply(shareButton, shown: ui.showsShare, icon: ui.shareButtonIcon, asset: "shortsShare")
        let side = ui.actionButtonSize ?? 34
        for button in [likeButton, dislikeButton, commentButton, shareButton] {
            actionSizes[ObjectIdentifier(button)]?.0.constant = side
            actionSizes[ObjectIdentifier(button)]?.1.constant = side
        }
        if let icon = ui.playButtonIcon {
            playButton.setImage(icon.withRenderingMode(.alwaysTemplate), for: .normal)
        }
        if let side = ui.playButtonSize {
            playWidth.constant = side
            playHeight.constant = side
        }
        hitArea.isUserInteractionEnabled = ui.showsSeekBar
        if let color = ui.seekBarProgressColor {
            seekFill.backgroundColor = color
        }
        if let color = ui.seekBarTrackColor {
            seekTrack.backgroundColor = color
        }
        applyChromeVisibility()
    }

    private func apply(_ button: UIButton, shown: Bool, icon: UIImage?, asset: String) {
        button.isHidden = !shown
        let image = icon?.withRenderingMode(.alwaysTemplate) ?? Self.icon(asset)
        button.setImage(image, for: .normal)
    }

    private static func icon(_ name: String) -> UIImage? {
        let image = UIImage.image(named: name)
        guard image.size != .zero else { return nil }
        return image.withRenderingMode(.alwaysTemplate)
    }

    @objc private func shareTapped() {
        onShare?()
    }

    @objc private func toggleTapped() {
        onToggle?()
    }

    @objc private func scrubbed(_ pan: UIPanGestureRecognizer) {
        guard KinescopeShortsUIConfig.showsSeekBar else { return }
        switch pan.state {
        case .began:
            anchorFraction = fraction
            dragConfirmed = false
            onScrubBegan?()
        case .changed:
            let translation = pan.translation(in: hitArea)
            if !dragConfirmed {
                guard abs(translation.x) > abs(translation.y), abs(translation.x) >= 12 else { return }
                confirmScrub()
            }
            guard dragConfirmed else { return }
            fraction = fractionFor(pan.location(in: contentView).x)
            updateScrubTime()
            setNeedsLayout()
        case .ended:
            finishScrub(commit: dragConfirmed)
        case .cancelled, .failed:
            fraction = anchorFraction
            finishScrub(commit: false)
        default:
            break
        }
    }

    private func fractionFor(_ x: CGFloat) -> CGFloat {
        let width = max(seekTrack.bounds.width, 1)
        return min(1, max(0, (x - seekTrack.frame.minX) / width))
    }

    private func updateScrubTime() {
        let live = durationProvider?() ?? 0
        if live > 0 {
            mediaDuration = live
        }
        let total = max(0, Int((mediaDuration * Double(fraction)).rounded(.down)))
        timeLabel.text = String(format: "%d:%02d", total / 60, total % 60)
        timeBubble.isHidden = false
        timeBubble.alpha = 1
        contentView.bringSubviewToFront(timeBubble)
        setNeedsLayout()
        layoutIfNeeded()
        layoutIfNeeded()
    }

    private func confirmScrub() {
        guard !dragConfirmed else { return }
        dragConfirmed = true
        chromeHidden = true
        playButton.isHidden = true
        seekTrack.isHidden = !KinescopeShortsUIConfig.showsSeekBar
        updateScrubTime()
        UIView.animate(withDuration: 0.15) {
            self.seekTrack.transform = CGAffineTransform(scaleX: 1, y: 2.5)
        }
        UIView.animate(withDuration: 0.2, animations: {
            self.chrome.forEach { $0.alpha = 0 }
        }, completion: { _ in
            guard self.dragConfirmed else { return }
            self.chrome.forEach { $0.isHidden = true }
        })
    }

    private func finishScrub(commit: Bool) {
        let keepPlaying = onScrubEnded?(commit ? fraction : nil) ?? isPlaying
        if !commit {
            fraction = anchorFraction
        }
        dragConfirmed = false
        isPlaying = keepPlaying
        if commit {
            hasStarted = true
        }
        UIView.animate(withDuration: 0.15) {
            self.seekTrack.transform = .identity
        }
        timeBubble.isHidden = true
        if chromeHidden {
            chromeHidden = false
            chrome.forEach {
                $0.isHidden = false
                $0.alpha = 0
            }
            UIView.animate(withDuration: 0.2) {
                self.chrome.forEach { $0.alpha = 1 }
            }
        }
        applyChromeVisibility()
        setNeedsLayout()
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard gestureRecognizer === videoTap else { return true }
        var view = touch.view
        while let current = view, current !== contentView {
            if current === hitArea || current === textStack || current === actions || current is UIControl {
                return false
            }
            view = current.superview
        }
        return true
    }

    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard gestureRecognizer === scrubPan else { return true }
        let velocity = scrubPan.velocity(in: contentView)
        let horizontal = abs(velocity.x)
        let vertical = abs(velocity.y)
        return horizontal > 80 && horizontal > vertical * 1.8
    }
}

/// Buffers a neighbouring page: it plays muted off screen until the first picture, then waits paused on that
/// frame. The page that becomes current takes the same player over without going back to the poster.
private final class ShortsPreload: NSObject, KinescopeVideoPlayerDelegate {
    let index: Int
    let player: KinescopeVideoPlayer
    let host = KinescopePlayerView()
    var onPrimed: (() -> Void)?
    private var handedOff = false
    private(set) var isPrimed = false
    /// The player is paused on a real frame, so the page can show it instead of the poster.
    private(set) var showsFrame = false
    private weak var placedOn: KinescopePlayerView?
    private var primeFallback: DispatchWorkItem?

    init(index: Int, videoId: String) {
        self.index = index
        player = KinescopeVideoPlayer(config: .init(videoId: videoId))
        super.init()
        prepareHost()
        player.setMaximumVideoHeight(480)
        player.revealPictureOnPlay()
        player.setVolume(0)
        player.setDelegate(delegate: self)
        player.attach(view: host)
        player.play()
    }

    /// The page just left. Keeps the player where it is, paused on the current picture.
    init(keeping player: KinescopeVideoPlayer, index: Int, placedOn view: KinescopePlayerView) {
        self.index = index
        self.player = player
        super.init()
        self.placedOn = view
        prepareHost()
        let ended: Bool = {
            guard let duration = player.duration, duration > 0 else { return false }
            return player.currentTime >= duration - 0.2
        }()
        if ended {
            showsFrame = false
            player.seek(to: 0)
        } else {
            showsFrame = true
        }
        isPrimed = true
        player.setVolume(0)
        player.pause()
        player.setDelegate(delegate: self)
    }

    private func prepareHost() {
        host.setLayout(with: .builder()
            .setGravity(.resizeAspect)
            .setOverlay(nil)
            .setControlPanel(nil)
            .setShadowOverlay(nil)
            .setPictureInPicture(false)
            .build())
        host.previewView.isHidden = true
        host.isUserInteractionEnabled = false
        host.alpha = 0.01
        host.frame = CGRect(x: 0, y: 0, width: 4, height: 4)
    }

    func isPlaced(on view: KinescopePlayerView) -> Bool {
        placedOn === view
    }

    /// Scrolling gives the page on screen the network. A picture that is already on screen stays put.
    func pausePrepare() {
        guard !handedOff, !isPrimed else { return }
        player.pause()
    }

    func resumePrepare() {
        guard !handedOff, !isPrimed else { return }
        player.play()
    }

    /// Moves the paused picture onto the page that will scroll into view.
    func place(on view: KinescopePlayerView) {
        guard !handedOff, placedOn !== view else { return }
        if let placedOn {
            player.detach(view: placedOn)
        } else {
            player.detach(view: host)
        }
        placedOn = view
        view.previewView.isHidden = true
        player.attach(view: view)
    }

    func returnToHost() {
        guard !handedOff, let placedOn else { return }
        player.detach(view: placedOn)
        self.placedOn = nil
        player.attach(view: host)
        player.pause()
    }

    /// Gives the buffered player to a page. Leaves it in place when it is already on that page.
    func takeOver(on view: KinescopePlayerView) -> KinescopeVideoPlayer {
        handedOff = true
        onPrimed = nil
        primeFallback?.cancel()
        if placedOn !== view {
            if let placedOn {
                player.detach(view: placedOn)
            } else {
                player.detach(view: host)
            }
            view.previewView.isHidden = true
            player.attach(view: view)
        }
        placedOn = nil
        host.removeFromSuperview()
        return player
    }

    func release() {
        handedOff = true
        onPrimed = nil
        primeFallback?.cancel()
        player.setDelegate(delegate: idleShortsDelegate)
        player.pause()
        if let placedOn {
            player.detach(view: placedOn)
        }
        player.detach(view: host)
        host.removeFromSuperview()
        player.relinquish()
    }

    func player(changedItemStatusTo status: AVPlayerItem.Status) {
        guard status == .readyToPlay, !handedOff, !isPrimed else { return }
        schedulePrimeFallback()
    }

    func player(playbackPositionMovedTo time: TimeInterval) {
        guard !handedOff, !isPrimed, time.isFinite, time >= 0.12 else { return }
        showsFrame = true
        finishPrepare()
    }

    func playerDidFinishPlaying() {
        guard !handedOff, !isPrimed else { return }
        finishPrepare()
    }

    private func schedulePrimeFallback() {
        guard primeFallback == nil else { return }
        let work = DispatchWorkItem { [weak self] in
            self?.finishPrepare()
        }
        primeFallback = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6, execute: work)
    }

    private func finishPrepare() {
        guard !handedOff, !isPrimed else { return }
        primeFallback?.cancel()
        primeFallback = nil
        isPrimed = true
        player.pause()
        player.setVolume(0)
        if !showsFrame {
            player.seek(to: 0)
        }
        onPrimed?()
    }
}

/// The opening poster, decoded off the main thread so the first feed does not pay for it.
enum KinescopeShortsArtwork {
    private static let lock = NSLock()
    private static var decoded: UIImage?

    private static var started = false

    static func warm() {
        lock.lock()
        let already = started
        started = true
        lock.unlock()
        guard !already else { return }
        DispatchQueue.global(qos: .utility).async {
            let ready = UIImage.image(named: "shortsStub").preparingForDisplay()
            lock.lock()
            decoded = ready
            lock.unlock()
        }
    }

    static func image() -> UIImage {
        warm()
        lock.lock()
        let ready = decoded
        lock.unlock()
        return ready ?? UIImage.image(named: "shortsStub")
    }
}

/// Receives nothing. Players that left the screen point here so their late events do not reach the feed.
private final class IdleShortsDelegate: NSObject, KinescopeVideoPlayerDelegate {}
private let idleShortsDelegate = IdleShortsDelegate()
