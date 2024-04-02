//
//  AnalyticsService.swift
//  KinescopeSDK
//
//  Created by Artemii Shabanov on 27.04.2021.
//

import Foundation

protocol AnalyticsService {
    func send(event: Analytics_Native)
}
