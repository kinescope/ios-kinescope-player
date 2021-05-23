//
//  Kinescope.swift
//  KinescopeSDK
//
//  Created by Никита Коробейников on 22.03.2021.
//

/// Holds entry point for sdk services
public enum Kinescope {

    // MARK: - Alias

    public typealias SharedManager = KinescopeConfigurable & KinescopeServicesProvider

    // MARK: - Properties

    /// Singleton entry to kinescope services
    public static let shared: SharedManager = Manager()

}
