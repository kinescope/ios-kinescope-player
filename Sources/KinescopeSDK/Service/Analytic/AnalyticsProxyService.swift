//
//  AnalyticsProxyService.swift
//  KinescopeSDK
//
//  Created by Nikita Korobeinikov on 02.04.2024.
//

import Foundation

/// Implementation of ``AnalyticsService`` which can delegate sending to other services
final class AnalyticsProxyService: AnalyticsService {

    private let wrappedServices: [AnalyticsService]

    init(wrappedServices: [AnalyticsService]) {
        self.wrappedServices = wrappedServices
    }

    func send(event: Analytics_Native) {
        wrappedServices.forEach { $0.send(event: event) }
    }

}
