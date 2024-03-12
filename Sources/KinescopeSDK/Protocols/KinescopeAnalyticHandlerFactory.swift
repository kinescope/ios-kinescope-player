//
//  KinescopeAnalyticHandlerFactory.swift
//  KinescopeSDK
//
//  Created by Nikita Korobeinikov on 12.03.2024.
//

import Foundation

protocol KinescopeAnalyticHandlerFactory {
    func provide(with dataStorage: InnerEventsDataStorage) -> InnerEventsHandler
}
