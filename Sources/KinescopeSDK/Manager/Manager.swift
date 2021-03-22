//
//  Manager.swift
//  KinescopeSDK
//
//  Created by Никита Коробейников on 22.03.2021.
//

/// Implementation of services
class Manager {

    // MARK: - Properties

    var config: KinescopeConfig?
}

// MARK: - KinescopeConfigurable

extension Manager: KinescopeConfigurable {

    func setConfig(_ config: KinescopeConfig) {
        self.config = config
    }

}
