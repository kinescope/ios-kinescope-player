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

    /// SDK version. Keep in step with `KinescopeSDK.podspec` and the git tag.
    /// Sent in analytics as the player version.
    public static let sdkVersion = "1.0.4"

    /// Singleton entry to kinescope services
    public static let shared: SharedManager = Manager()

    static var analytic: KinescopeAnalyticHandlerFactory? {
        return (shared as? Manager)?.analyticFactory
    }

    static var analyticDelegate: KinescopeAnalyticsDelegate? = nil
}
