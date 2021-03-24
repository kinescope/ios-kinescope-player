import Foundation

enum ConfigStorage {

    // MARK: - Nested

    private struct Config: Decodable {

        // MARK: - Properties

        let users: [User]

        // MARK: - Decodable

        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let users = try container.decode(Dictionary<String, String>.self)
            self.users = users.map { .init(name: $0.0, apiKey: $0.1) }
        }
    }

    // MARK: - Public Methods

    static func read() -> [User] {
        var users: [User] = []

        let semaphore = DispatchSemaphore(value: 0)

        DispatchQueue.global(qos: .utility).async {
            guard
                let path = Bundle.main.path(forResource: "KinescopeConfig", ofType: "plist"),
                let data = FileManager.default.contents(atPath: path),
                let config = try? PropertyListDecoder().decode(Config.self, from: data)
            else {
                return
            }

            users = config.users

            semaphore.signal()
        }

        semaphore.wait()

        return users
    }
}
