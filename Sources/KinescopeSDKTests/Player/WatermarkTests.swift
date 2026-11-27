import XCTest
@testable import KinescopeSDK

final class WatermarkTests: XCTestCase {

    private func decode(_ json: String) throws -> KinescopeAnalyticEndpoints {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(KinescopeAnalyticEndpoints.self, from: Data(json.utf8))
    }

    func testFullWatermarkIsDecoded() throws {
        let sdk = try decode("""
        {"metric_url": "https://m.example/1", "watermark": {"text": "user-42", "mode": "stripes",
         "scale": 0.5, "display_timeout": {"visible": 3000, "hidden": 1000}, "color": "#FF000080"}}
        """)
        XCTAssertEqual(sdk.metricUrl, "https://m.example/1")
        let watermark = try XCTUnwrap(sdk.watermark)
        XCTAssertEqual(watermark.text, "user-42")
        XCTAssertEqual(watermark.mode, "stripes")
        XCTAssertEqual(watermark.scale, 0.5)
        XCTAssertEqual(watermark.displayTimeout, .init(visible: 3000, hidden: 1000))
        XCTAssertEqual(watermark.color, "#FF000080")
    }

    func testNumericTimeoutIsUsedForBoth() throws {
        let sdk = try decode(#"{"watermark": {"text": "a", "display_timeout": 2000}}"#)
        XCTAssertEqual(sdk.watermark?.displayTimeout, .init(visible: 2000, hidden: 2000))
    }

    func testBrokenWatermarkKeepsMetricUrl() throws {
        let sdk = try decode(#"{"metric_url": "https://m.example/1", "watermark": "oops"}"#)
        XCTAssertEqual(sdk.metricUrl, "https://m.example/1")
        XCTAssertNil(sdk.watermark)
    }

    func testStyleDefaults() throws {
        let style = try XCTUnwrap(WatermarkStyle(KinescopeWatermark(text: "  user-42 ")))
        XCTAssertEqual(style.text, "user-42")
        XCTAssertEqual(style.mode, .random)
        XCTAssertEqual(style.scale, WatermarkStyle.defaultScale)
        XCTAssertFalse(style.blinks)
        XCTAssertEqual(style.color, WatermarkStyle.defaultColor)
    }

    func testBlankTextMeansNoWatermark() {
        XCTAssertNil(WatermarkStyle(KinescopeWatermark(text: "   ")))
        XCTAssertNil(WatermarkStyle(nil))
    }

    func testStyleValues() throws {
        let style = try XCTUnwrap(WatermarkStyle(KinescopeWatermark(text: "a",
                                                                    mode: "STRIPES",
                                                                    scale: 4,
                                                                    displayTimeout: .init(visible: 3000, hidden: 1000),
                                                                    color: "#0f08")))
        XCTAssertEqual(style.mode, .stripes)
        XCTAssertEqual(style.scale, 1)
        XCTAssertEqual(style.visible, 3)
        XCTAssertEqual(style.hidden, 1)
        XCTAssertTrue(style.blinks)
        XCTAssertEqual(style.color, UIColor(red: 0, green: 1, blue: 0, alpha: CGFloat(0x88) / 255))
    }

    func testCssColors() {
        XCTAssertEqual(WatermarkStyle.color(css: "#fff"), UIColor(red: 1, green: 1, blue: 1, alpha: 1))
        XCTAssertEqual(WatermarkStyle.color(css: "336699"), UIColor(red: 0x33 / 255.0, green: 0x66 / 255.0, blue: 0x99 / 255.0, alpha: 1))
        XCTAssertNil(WatermarkStyle.color(css: "#12345"))
        XCTAssertNil(WatermarkStyle.color(css: "red"))
        XCTAssertNil(WatermarkStyle.color(css: nil))
    }
}
