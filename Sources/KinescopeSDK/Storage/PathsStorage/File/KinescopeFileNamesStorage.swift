//
//  KinescopeFileNamesStorage.swift
//  KinescopeSDK
//
//  Created by Artemii Shabanov on 06.04.2021.
//

import Foundation

/// Manages file name for its id pairs storing
/// It should provide consistency of saved and read names
protocol KinescopeFileNamesStorage {
    /// Saves file name by its id
    /// - Parameters:
    ///   - name: file name
    ///   - fileId: file id
    func saveFile(name: String, id fileId: String)
    /// Returns file name by id
    /// - Parameter fileId: file id
    func readFileName(by fileId: String) -> String?
    /// Returns all saved names
    func fetchFileNames() -> [String]
    /// Deletes file name to id pair from device storage
    /// Returns this name
    @discardableResult
    func deleteFileName(by fileId: String) -> String?
}
