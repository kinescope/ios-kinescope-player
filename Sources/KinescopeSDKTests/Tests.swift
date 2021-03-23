//
//  Tests.swift
//  KinescopeSDKTests
//
//  Created by Никита Коробейников on 20.03.2021.
//

import XCTest
import KinescopeSDK

/// Just stub for tests
final class Tests: XCTestCase {

    func stubTest() {
        Kinescope.shared.setConfig(.init(apiKey: "stub"))
    }

}
