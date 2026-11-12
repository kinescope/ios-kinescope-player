import Foundation

/// One downloadable rendition. `height` is the picture height in pixels.
public struct KinescopeOfflineQuality: Equatable {
    public let name: String
    public let height: Int

    public init(name: String, height: Int) {
        self.name = name
        self.height = height
    }
}

/// Lists renditions for an offline download. Uses `qualityMap` when the video has one,
/// otherwise reads `RESOLUTION` tags from the HLS master playlist.
public enum KinescopeOffline {

    public static func qualities(for video: KinescopeVideo,
                                 completion: @escaping ([KinescopeOfflineQuality]) -> Void) {
        let listed = qualities(from: video.qualityMap ?? [])
        if !listed.isEmpty {
            DispatchQueue.main.async {
                completion(listed)
            }
            return
        }
        guard let url = URL(string: video.hlsLink) else {
            DispatchQueue.main.async {
                completion([])
            }
            return
        }
        URLSession.shared.dataTask(with: url) { data, _, _ in
            let playlist = data.flatMap { String(data: $0, encoding: .utf8) } ?? ""
            let heights = variantHeights(in: playlist)
            let items = heights.map { KinescopeOfflineQuality(name: "\($0)p", height: $0) }
            DispatchQueue.main.async {
                completion(items)
            }
        }.resume()
    }

    static func qualities(from assets: [KinescopeVideoAsset]) -> [KinescopeOfflineQuality] {
        var seen = Set<Int>()
        return assets
            .sorted { $0.height > $1.height }
            .compactMap { asset in
                guard asset.height > 0, seen.insert(asset.height).inserted else {
                    return nil
                }
                let name = asset.name.isEmpty ? "\(asset.height)p" : asset.name
                return KinescopeOfflineQuality(name: name, height: asset.height)
            }
    }

    static func variantHeights(in playlist: String) -> [Int] {
        var seen = Set<Int>()
        var heights: [Int] = []
        for line in playlist.split(whereSeparator: \.isNewline) where line.contains("RESOLUTION=") {
            guard let range = line.range(of: "RESOLUTION="),
                  let token = line[range.upperBound...].split(separator: ",").first else {
                continue
            }
            let sides = token.split(separator: "x")
            guard sides.count == 2, let height = Int(sides[1]), height > 0, seen.insert(height).inserted else {
                continue
            }
            heights.append(height)
        }
        return heights.sorted(by: >)
    }

}
