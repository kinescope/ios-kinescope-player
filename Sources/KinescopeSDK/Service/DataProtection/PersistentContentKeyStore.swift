import Foundation

/// Offline FairPlay keys, one file per video. Playback reads the key without the license server.
enum PersistentContentKeyStore {

    private static let folderName = "KinescopeFairPlay"

    static func exists(for videoId: String) -> Bool {
        guard let url = fileURL(for: videoId) else {
            return false
        }
        return FileManager.default.fileExists(atPath: url.path)
    }

    static func key(for videoId: String) -> Data? {
        guard let url = fileURL(for: videoId) else {
            return nil
        }
        return try? Data(contentsOf: url)
    }

    static func save(_ key: Data, for videoId: String) {
        guard let url = fileURL(for: videoId) else {
            return
        }
        let folder = url.deletingLastPathComponent()
        do {
            try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
            try key.write(to: url, options: .completeFileProtectionUntilFirstUserAuthentication)
        } catch {
            Kinescope.shared.logger?.log(error: error, level: KinescopeLoggerLevel.drm)
        }
    }

    static func delete(for videoId: String) {
        guard let url = fileURL(for: videoId) else {
            return
        }
        try? FileManager.default.removeItem(at: url)
    }

    private static func fileURL(for videoId: String) -> URL? {
        let safe = videoId.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? videoId
        guard !safe.isEmpty,
              let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            return nil
        }
        return base.appendingPathComponent(folderName, isDirectory: true).appendingPathComponent(safe)
    }

}
