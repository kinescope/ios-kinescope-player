import Foundation

/// A video row from the dashboard list (`GET /v1/videos`).
public struct KinescopeLibraryVideo: Equatable {
    public let id: String
    public let title: String
    public let posterURL: URL?
    public let duration: TimeInterval?
    public let summary: String?
}

public enum KinescopeDashboardError: Error {
    case missingAPIKey
    case badResponse
}

/// Dashboard API. Requires `KinescopeConfig.apiKey`.
public enum KinescopeDashboard {

    private static var cachedPages: [String: [KinescopeLibraryVideo]] = [:]
    private static var inflight: [String: [(Result<[KinescopeLibraryVideo], Error>) -> Void]] = [:]

    /// `projectId` and `folderId` match Android `KinescopeDemoConfig`: a blank value is no filter.
    /// Only `projectId` limits the feed to that project; `folderId` narrows it further.
    public static func videos(page: Int = 1,
                              perPage: Int = 100,
                              projectId: String? = nil,
                              folderId: String? = nil,
                              completion: @escaping (Result<[KinescopeLibraryVideo], Error>) -> Void) {
        let project = Self.filter(projectId)
        let folder = Self.filter(folderId)
        let key = "\(page)x\(perPage)|\(project ?? "")|\(folder ?? "")"
        if let cached = cachedPages[key] {
            DispatchQueue.main.async {
                completion(.success(cached))
            }
            return
        }
        if inflight[key] != nil {
            inflight[key]?.append(completion)
            return
        }
        inflight[key] = [completion]
        guard let apiKey = Kinescope.shared.config?.apiKey, !apiKey.isEmpty else {
            finish(key, .failure(KinescopeDashboardError.missingAPIKey))
            return
        }
        var components = URLComponents(string: "https://api.kinescope.io/v1/videos/")
        var query = [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "per_page", value: String(perPage))
        ]
        if let project {
            query.append(URLQueryItem(name: "project_id", value: project))
        }
        if let folder {
            query.append(URLQueryItem(name: "folder_id", value: folder))
        }
        components?.queryItems = query
        guard let url = components?.url else {
            finish(key, .failure(KinescopeDashboardError.badResponse))
            return
        }
        var request = URLRequest(url: url)
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: request) { data, _, error in
            let result: Result<[KinescopeLibraryVideo], Error>
            if let error {
                result = .failure(error)
            } else if let data,
                      let envelope = try? JSONDecoder().decode(VideoListEnvelope.self, from: data) {
                result = .success(envelope.videos)
            } else {
                result = .failure(KinescopeDashboardError.badResponse)
            }
            DispatchQueue.main.async {
                if case .success(let videos) = result {
                    cachedPages[key] = videos
                }
                finish(key, result)
            }
        }.resume()
    }

    private static func filter(_ value: String?) -> String? {
        let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let trimmed, !trimmed.isEmpty else {
            return nil
        }
        return trimmed
    }

    private static func finish(_ key: String, _ result: Result<[KinescopeLibraryVideo], Error>) {
        let callbacks = inflight.removeValue(forKey: key) ?? []
        DispatchQueue.main.async {
            callbacks.forEach { $0(result) }
        }
    }

}

private struct VideoListEnvelope: Decodable {
    let videos: [KinescopeLibraryVideo]

    private enum CodingKeys: String, CodingKey {
        case data
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        videos = try container.decode([VideoItem].self, forKey: .data).map(\.video)
    }
}

private struct VideoItem: Decodable {
    let id: String
    let title: String?
    let poster: Poster?
    let duration: TimeInterval?
    let description: String?

    var video: KinescopeLibraryVideo {
        let name = title?.trimmingCharacters(in: .whitespacesAndNewlines)
        let about = description?.trimmingCharacters(in: .whitespacesAndNewlines)
        return KinescopeLibraryVideo(id: id,
                                     title: (name?.isEmpty == false ? name! : id),
                                     posterURL: poster?.url,
                                     duration: duration,
                                     summary: about?.isEmpty == false ? about : nil)
    }
}

private struct Poster: Decodable {
    let xs: String?
    let sm: String?
    let md: String?
    let original: String?

    var url: URL? {
        let raw = sm ?? md ?? xs ?? original
        guard let raw, !raw.isEmpty else {
            return nil
        }
        return URL(string: raw)
    }
}
