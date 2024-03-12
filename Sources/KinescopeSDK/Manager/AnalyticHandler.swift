//
//  AnalyticHandler.swift
//  KinescopeSDK
//
//  Created by Nikita Korobeinikov on 12.03.2024.
//

import Foundation

final class AnalyticHandler: KinescopeAnalyticHandlerFactory {
    
    // MARK: - Properties

    private let service: AnalyticsService

    // MARK: - Init

    init(service: AnalyticsService) {
        self.service = service
    }

    // MARK: - KinescopeAnalyticHandlerFactory

    func provide(with dataStorage: any InnerEventsDataStorage) -> any InnerEventsHandler {
        InnerEventsProtoHandler(service: service, dataStorage: dataStorage)
    }
}
