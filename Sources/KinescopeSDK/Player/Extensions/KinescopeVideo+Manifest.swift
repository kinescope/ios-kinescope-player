//
//  KinescopeVideo+Manifest.swift
//  KinescopeSDK
//
//  Created by Artemii Shabanov on 11.05.2021.
//

import Foundation
import GoSwiftyM3U8

extension KinescopeVideo {

    var qualities: [String] {
        guard let tags = manifest?.tags.streamTags else {
            return []
        }
        return tags.compactMap { $0.quality }
    }

    func link(for quality: String) -> String? {
        guard
            let tags = manifest?.tags.streamTags ,
            let url = tags.first(where: { $0.quality == quality })?.uri
        else {
            return nil
        }
        return manifest?.baseUrl.deletingLastPathComponent().appendingPathComponent(url).absoluteString
    }

}

private extension GoSwiftyM3U8.BaseAttributedTag {

    var quality: String? {
        if let attribute = attributes.first(where: { $0.key == "RESOLUTION" }) {
            var string = string(forResulution: attribute.value)
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

    private func string(forResulution resulution: String) -> String? {
        switch resulution {
        case "426x240":
            return "240p"
        case "640x360":
            return "360p"
        case "854x480":
            return "480p"
        case "1280x720":
            return "720p"
        case "1920x1080":
            return "1080p"
        case "2560x1440":
            return "1440p"
        case "3840x2160":
            return "2160p"
        default:
            return resulution
        }
    }

}
