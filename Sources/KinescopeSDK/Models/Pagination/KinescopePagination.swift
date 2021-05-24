//
//  KinescopePagination.swift
//  KinescopeSDK
//
//  Created by Никита Коробейников on 23.03.2021.
//

/// Pagination model
public struct KinescopePagination: Codable {
    public let page: Int
    public let perPage: Int
    public let total: Int
}
