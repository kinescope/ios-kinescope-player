//
//  KinescopeFileNamesStorage.swift
//  KinescopeSDK
//
//  Created by Artemii Shabanov on 06.04.2021.
//

import Foundation

/// It should provide consistency of saved and read names
protocol KinescopeFileNamesStorage {
    func saveFile(name: String, id fileId: String)
    func readFileName(by fileId: String) -> String?
    func fetchFileNames() -> [String]
    @discardableResult
    func deleteFileName(by fileId: String) -> String?
}
