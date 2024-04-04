//
//  AnalyticsLoggingService.swift
//  KinescopeSDK
//
//  Created by Nikita Korobeinikov on 02.04.2024.
//

import Foundation

/// Implementation of ``AnalyticsService`` which can delegate sending to client code
final class AnalyticsLoggingService: AnalyticsService {

    func send(event: Analytics_Native, for video: KinescopeVideo) {
        Kinescope.analyticDelegate?.didSendAnalytics(event: event.event,
                                                     with: event.textFormatString())
    }

}
