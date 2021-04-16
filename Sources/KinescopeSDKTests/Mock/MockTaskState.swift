//
//  MockTaskState.swift
//  KinescopeSDKTests
//
//  Created by Artemii Shabanov on 12.04.2021.
//

import Foundation

enum MockTaskState {
    case resume(MockResult)
    case cancel
    case suspend
}
