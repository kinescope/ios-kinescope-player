//
//  KinescopeInspectError.swift
//  KinescopeSDK
//
//  Created by Никита Коробейников on 23.03.2021.
//

import Foundation

/// Enumeration of possible negative cases while downloading content
public enum KinescopeInspectError: Error, LocalizedError {

    /// Network problems
    case network
    /// Video not found
    case notFound
    /// Denied by dashboard or by system when saving in local storage
    case denied
    /// Unexpected error
    case unknown(Error)

    public var errorDescription: String? {
        switch self {
        case .network:
            return "Нет соединения с сервером"
        case .notFound:
            return "Трансляция или видео не найдены"
        case .denied:
            return "Доступ к видео запрещён"
        case .unknown(let error):
            if let server = error as? ServerError, !server.message.isEmpty {
                return server.message
            }
            let text = error.localizedDescription
            if text.contains("KinescopeInspectError") {
                return "Не удалось открыть трансляцию"
            }
            return text
        }
    }

}
