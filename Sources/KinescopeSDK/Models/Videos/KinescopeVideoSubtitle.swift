import Foundation

public struct KinescopeVideoSubtitle: Codable {
    public let id: String
    public let description: String
    public let language: String
    public let url: String
}

extension KinescopeVideoSubtitle {
    var title: String {
        return Locale(identifier: language).localizedString(forIdentifier: language) ?? language
    }
}
