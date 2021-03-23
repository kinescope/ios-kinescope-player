//
//  Inspector.swift
//  KinescopeSDK
//
//  Created by Никита Коробейников on 23.03.2021.
//

// MARK: - KinescopeInspectable

class Inspector: KinescopeInspectable {

    // MARK: - Properties

    private let apiKey: String

    // MARK: - Initialisation

    init(apiKey: String) {
        self.apiKey = apiKey
    }

    // MARK: - Methods

    func list(onSuccess: (KinescopeVideoListResponse) -> Void, onError: (KinescopeInspectError) -> Void) {
        preconditionFailure("Implement")
    }

}
