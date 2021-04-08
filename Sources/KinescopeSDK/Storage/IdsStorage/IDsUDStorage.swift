//
//  IDsUDStorage.swift
//  KinescopeSDK
//
//  Created by Artemii Shabanov on 07.04.2021.
//

import Foundation

final class IDsUDStorage: IDsStorage {

    // MARK: - Nested Types

    private enum Keys {
        static let dictKey = "io.kinescope.ids"
    }

    // MARK: - API

    func save(id: String, by url: String) {
        guard var dict = getDict() else {
            let newDict: [String: String] = [url: id]
            UserDefaults.standard.set(newDict, forKey: Keys.dictKey)
            return
        }
        dict[url] = id
        UserDefaults.standard.set(dict, forKey: Keys.dictKey)
    }

    func contains(url: String) -> Bool {
        return getDict()?.keys.contains(url) ?? false
    }

    func readID(by url: String) -> String? {
        guard let dict = getDict() else {
            return nil
        }
        return dict[url]
    }

    @discardableResult
    func deleteID(by url: String) -> String? {
        guard var dict = getDict() else {
            return nil
        }
        if dict.keys.contains(url) {
            let value = dict[url]
            dict.removeValue(forKey: url)
            UserDefaults.standard.set(dict, forKey: Keys.dictKey)
            return value
        }
        return nil
    }

    // MARK: - Private

    private func getDict() -> [String: String]? {
        return UserDefaults.standard.object(forKey: Keys.dictKey) as? [String: String]
    }

}
