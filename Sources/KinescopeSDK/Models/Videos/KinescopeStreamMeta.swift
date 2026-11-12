//
//  KinescopeStreamMeta.swift
//  KinescopeSDK
//
//  Created by Nikita Korobeinikov on 06.03.2024.
//

import Foundation

public struct KinescopeStreamMeta: Codable {
    public let startsAt: Date?

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let raw = try container.decodeIfPresent(String.self, forKey: .startsAt) {
            startsAt = KinescopeDate.parse(raw)
        } else {
            startsAt = nil
        }
    }

    private enum CodingKeys: String, CodingKey {
        case startsAt
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(startsAt, forKey: .startsAt)
    }
}

enum KinescopeDate {
    static func parse(_ raw: String) -> Date? {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            return nil
        }
        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = iso.date(from: trimmed) {
            return date
        }
        iso.formatOptions = [.withInternetDateTime]
        if let date = iso.date(from: trimmed) {
            return date
        }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        for format in ["yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX",
                       "yyyy-MM-dd'T'HH:mm:ssXXXXX",
                       "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'",
                       "yyyy-MM-dd'T'HH:mm:ss'Z'"] {
            formatter.dateFormat = format
            if let date = formatter.date(from: trimmed) {
                return date
            }
        }
        return nil
    }
}
