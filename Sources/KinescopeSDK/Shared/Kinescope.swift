//
//  Kinescope.swift
//  KinescopeSDK
//
//  Created by Никита Коробейников on 22.03.2021.
//

public enum Kinescope {

    // MARK: - Alias

    public typealias SharedManager = KinescopeConfigurable & KinescopeServicesProvider

    // MARK: - Properties

    /// Singleton entry to kinescope services
    public static let shared: SharedManager = Manager()

    static var analytic: KinescopeAnalyticHandlerFactory? {
        return (shared as? Manager)?.analyticFactory
    }
}
