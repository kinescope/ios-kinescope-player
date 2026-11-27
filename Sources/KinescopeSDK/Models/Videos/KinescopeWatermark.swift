//
//  KinescopeWatermark.swift
//  KinescopeSDK
//

import Foundation

/// Watermark from `sdk.watermark` of the video metadata. It is set up in the Kinescope dashboard
/// for the player template, with the same meaning as `watermark` in the web player.
public struct KinescopeWatermark: Codable, Equatable {

    /// Show and hide time in milliseconds.
    public struct DisplayTimeout: Codable, Equatable {
        public let visible: Double
        public let hidden: Double

        enum CodingKeys: String, CodingKey {
            case visible
            case hidden
        }

        public init(visible: Double, hidden: Double) {
            self.visible = visible
            self.hidden = hidden
        }

        /// A number (same show and hide time) or `{ "visible": ms, "hidden": ms }`.
        public init(from decoder: Decoder) throws {
            if let single = try? decoder.singleValueContainer(), let both = try? single.decode(Double.self) {
                visible = both
                hidden = both
                return
            }
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let visible = (try? container.decodeIfPresent(Double.self, forKey: .visible)) ?? 0
            self.visible = visible
            hidden = (try? container.decodeIfPresent(Double.self, forKey: .hidden)) ?? visible
        }
    }

    /// Watermark text. Empty or blank: no watermark.
    public let text: String?
    /// `random` (default): the text jumps to a new place. `stripes`: diagonal rows over the frame.
    public let mode: String?
    /// Text width relative to the picture width, `0.25` by default.
    public let scale: Double?
    /// Blinking. `nil`: always shown.
    public let displayTimeout: DisplayTimeout?
    /// CSS colour `#RGB`, `#RGBA`, `#RRGGBB` or `#RRGGBBAA`. White at 40% by default.
    public let color: String?

    enum CodingKeys: String, CodingKey {
        case text
        case mode
        case scale
        case displayTimeout
        case color
    }

    public init(text: String?,
                mode: String? = nil,
                scale: Double? = nil,
                displayTimeout: DisplayTimeout? = nil,
                color: String? = nil) {
        self.text = text
        self.mode = mode
        self.scale = scale
        self.displayTimeout = displayTimeout
        self.color = color
    }

    /// A field of the wrong type is skipped, so a bad value never drops the whole watermark.
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        text = try? container.decodeIfPresent(String.self, forKey: .text)
        mode = try? container.decodeIfPresent(String.self, forKey: .mode)
        scale = try? container.decodeIfPresent(Double.self, forKey: .scale)
        displayTimeout = try? container.decodeIfPresent(DisplayTimeout.self, forKey: .displayTimeout)
        color = try? container.decodeIfPresent(String.self, forKey: .color)
    }
}
