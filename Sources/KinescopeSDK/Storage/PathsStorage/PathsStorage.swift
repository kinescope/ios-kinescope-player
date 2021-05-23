//
//  PathsStorage.swift
//  KinescopeSDK
//
//  Created by Artemii Shabanov on 08.04.2021.
//

import Foundation

/// Manages urls by ids pairs storing
protocol PathsStorage {
    func save(relativeUrl: String, id: String)
    func readUrl(by id: String) -> String?
    func fetchIds() -> [String]
    @discardableResult
    func deleteUrl(by id: String) -> String?
}
