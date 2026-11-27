import XCTest
@testable import KinescopeSDK

final class AudioOnlyTests: XCTestCase {

    private let master = URL(string: "https://kinescope.io/a85a75ec/master.m3u8")!

    func testDefaultAudioRenditionIsResolvedAgainstMaster() {
        let playlist = """
        #EXTM3U
        #EXT-X-MEDIA:TYPE=AUDIO,GROUP-ID="audio/mp4a",NAME="Deutsch",LANGUAGE="de",URI="media.m3u8?quality=480&type=audio&lang=de"
        #EXT-X-MEDIA:TYPE=AUDIO,GROUP-ID="audio/mp4a",NAME="English",DEFAULT=YES,LANGUAGE="en",URI="media.m3u8?quality=480&type=audio&lang=en"
        #EXT-X-MEDIA:TYPE=SUBTITLES,GROUP-ID="subs",NAME="Русский",DEFAULT=YES,URI="media.m3u8?id=1&type=subtitle"
        #EXT-X-STREAM-INF:BANDWIDTH=1971736,CODECS="avc1.4D401F,mp4a.40.2",RESOLUTION=478x854,AUDIO="audio/mp4a"
        media.m3u8?quality=480&type=video
        """
        let url = KinescopeVideoPlayer.audioRenditionURL(in: playlist, master: master)
        XCTAssertEqual(url?.absoluteString, "https://kinescope.io/a85a75ec/media.m3u8?quality=480&type=audio&lang=en")
    }

    func testFirstAudioRenditionWithoutDefault() {
        let playlist = """
        #EXT-X-MEDIA:TYPE=AUDIO,GROUP-ID="a",NAME="One",URI="https://cdn.example/one.m3u8"
        #EXT-X-MEDIA:TYPE=AUDIO,GROUP-ID="a",NAME="Two",URI="two.m3u8"
        """
        let url = KinescopeVideoPlayer.audioRenditionURL(in: playlist, master: master)
        XCTAssertEqual(url?.absoluteString, "https://cdn.example/one.m3u8")
    }

    func testMuxedStreamHasNoAudioOnly() {
        let playlist = """
        #EXTM3U
        #EXT-X-STREAM-INF:BANDWIDTH=1000000,CODECS="avc1.4D401F,mp4a.40.2"
        video.m3u8
        """
        XCTAssertNil(KinescopeVideoPlayer.audioRenditionURL(in: playlist, master: master))
    }

    func testQualityNumberComesFromTheName() {
        XCTAssertEqual(KinescopeVideoPlayer.qualityNumber(in: "480p"), 480)
        XCTAssertEqual(KinescopeVideoPlayer.qualityNumber(in: " 1080p60 "), 1080)
        XCTAssertEqual(KinescopeVideoPlayer.qualityNumber(in: "2160"), 2160)
        XCTAssertNil(KinescopeVideoPlayer.qualityNumber(in: "Auto"))
        XCTAssertNil(KinescopeVideoPlayer.qualityNumber(in: "HD"))
    }

    func testAudioOnlyNames() {
        XCTAssertTrue(KinescopeVideoPlayer.isAudioOnlyName("audio"))
        XCTAssertTrue(KinescopeVideoPlayer.isAudioOnlyName(" Audio_Only "))
        XCTAssertTrue(KinescopeVideoPlayer.isAudioOnlyName(L10n.Player.audio))
        XCTAssertFalse(KinescopeVideoPlayer.isAudioOnlyName("720p"))
        XCTAssertFalse(KinescopeVideoPlayer.isAudioOnlyName(L10n.Player.auto))
    }
}
