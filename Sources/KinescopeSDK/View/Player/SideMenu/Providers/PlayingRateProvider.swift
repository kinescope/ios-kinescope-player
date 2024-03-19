//
//  PlayingRateProvider.swift
//  KinescopeSDK
//
//  Created by Nikita Korobeinikov on 13.03.2024.
//

import AVFoundation

protocol PlayingRateSource: AnyObject {
    var currentRate: KinescopePlayingRate { get }
}

final class PlayingRateProvider: SideMenuItemsProvider {
    
    // MARK: - Properties

    private weak var rateSource: PlayingRateSource?

    // MARK: - SideMenuItemsProvider
    
    var selectedTitle: String {
        rateSource?.currentRate.title ?? L10n.Player.normal
    }

    var items: [SideMenu.Item] {
        KinescopePlayingRate.allCases.compactMap { speed -> SideMenu.Item in
            let selected = selectedTitle.trimmingCharacters(in: .symbols) == speed.title
            return .checkmark(title: .init(string: speed.title), selected: selected)
        }
    }

    // MARK: - Init

    init(rateSource: PlayingRateSource) {
        self.rateSource = rateSource
    }
}
