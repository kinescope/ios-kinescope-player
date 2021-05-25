//
//  KinescopeVideo+Manifest.swift
//  KinescopeSDK
//
//  Created by Artemii Shabanov on 11.05.2021.
//

import Foundation
import GoSwiftyM3U8

extension KinescopeVideo {

    /// List of available qualities in string format based on manifest
    var qualities: [String] {
        guard let tags = manifest?.tags.streamTags else {
            return []
        }
        return tags.compactMap { $0.quality }.sorted(by: { weight(for: $0) < weight(for: $1) })
    }

    /// Link for concrete quality manfiest
    func link(for quality: String) -> String? {
        guard
            let tags = manifest?.tags.streamTags ,
            let urlString = tags.first(where: { $0.quality == quality })?.uri
        else {
            return nil
        }
        if (urlString.range(of: "http://") != nil || urlString.range(of: "https://") != nil) {
            return urlString
        }
        return manifest?.baseUrl.deletingLastPathComponent().appendingPathComponent(urlString).absoluteString
    }

    /// User for sorting
    private func weight(for resolution: String) -> Int {
        switch resolution {
        case "2160p":
            return 0
        case "1440p":
            return 1
        case "1080p":
            return 2
        case "720p":
            return 3
        case "480p":
            return 4
        case "360p":
            return 5
        case "240p":
            return 6
        default:
            return 10
        }
    }

}

private extension GoSwiftyM3U8.BaseAttributedTag {

    var quality: String? {
        if let attribute = attributes.first(where: { $0.key == "RESOLUTION" }) {
            var string = getString(forResulution: attribute.value)
            if let frameRate = frameRate, Int(frameRate) ?? 0 > 30 {
                string?.append(frameRate)
            }
            return string
        } else {
            return nil
        }
    }

    var frameRate: String? {
        if let attribute = attributes.first(where: { $0.key == "FRAME-RATE" }),
           let double = Double(attribute.value) {
            return String(Int(double))
        } else {
            return nil
        }
    }

    func getString(forResulution resulution: String) -> String? {
        if resulution.contains("240") {
            return "240p"
        }
        if resulution.contains("360") {
            return "360p"
        }
        if resulution.contains("480") {
            return "480p"
        }
        if resulution.contains("720") {
            return "720p"
        }
        if resulution.contains("1080") {
            return "1080p"
        }
        if resulution.contains("1440") {
            return "1440p"
        }
        if resulution.contains("2160") {
            return "2160p"
        }
        return resulution
    }

}
