//
//  IdsStorage.swift
//  KinescopeSDK
//
//  Created by Artemii Shabanov on 08.04.2021.
//

import Foundation

protocol IDsStorage {
    func save(id: String, by url: String)
    func contains(url: String) -> Bool
    func readID(by url: String) -> String?
    @discardableResult
    func deleteID(by url: String) -> String?
}
