//
//  Kinescope.swift
//  KinescopeSDK
//
//  Created by Никита Коробейников on 22.03.2021.
//

public enum Kinescope {

    // MARK: - Alias

    typealias SharedManager = KinescopeConfigurable

    // MARK: - Properties

    /// Singleton entry to kinescope services
    static let shared: SharedManager = Manager()

}
