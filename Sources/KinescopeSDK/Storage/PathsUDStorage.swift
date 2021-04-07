//
//  PathsUDStorage.swift
//  KinescopeSDK
//
//  Created by Artemii Shabanov on 06.04.2021.
//

import Foundation

class PathsUDStorage {

    // MARK: - Private Properties

    private let dictKey: String

    // MARK: - Lifecycle

    init(suffix: String) {
        self.dictKey = "io.kinescope.dict" + suffix
    }

    // MARK: - API

    func save(relativeUrl: String, id: String) {
        guard var dict = getDict() else {
            let newDict: [String: String] = [id: relativeUrl]
            UserDefaults.standard.set(newDict, forKey: dictKey)
            return
        }
        dict[id] = relativeUrl
        UserDefaults.standard.set(dict, forKey: dictKey)
    }

    func readUrl(by id: String) -> String? {
        guard let dict = getDict() else { return nil }
        return dict[id]
    }

    func fetchIds() -> [String] {
        guard let dict = getDict() else { return [] }
        return Array(dict.keys)
    }

    func deleteUrl(by id: String) -> String? {
        guard var dict = getDict() else { return nil }
        if dict.keys.contains(id) {
            let value = dict[id]
            dict.removeValue(forKey: id)
            UserDefaults.standard.set(dict, forKey: dictKey)
            return value
        }
        return nil
    }

    // MARK: - Private

    private func getDict() -> [String: String]? {
        return UserDefaults.standard.object(forKey: dictKey) as? [String: String]
    }

}
