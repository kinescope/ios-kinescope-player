//
//  VideoQualityProvider.swift
//  KinescopeSDK
//
//  Created by Nikita Korobeinikov on 13.03.2024.
//

import AVFoundation

protocol VideoQualitySource: QualitySelectionProvider {
    var currentQuality: String { get }
    var availableAssets: [KinescopeVideoAsset] { get }
}

final class VideoQualityProvider: SideMenuItemsProvider {

    // MARK: - Properties

    private weak var source: VideoQualitySource?

    // MARK: - SideMenuItemsProvider

    var selectedTitle: String {
        source?.currentQuality ?? L10n.Player.auto
    }

    var items: [SideMenu.Item] {
        let qualities = source?.availableAssets ?? []
        var items = qualities.compactMap { quality -> SideMenu.Item in
            let selected = selectedTitle.trimmingCharacters(in: .symbols) == quality.name
            return .checkmark(title: .init(string: quality.name), selected: selected)
        }

        let autoTitle = NSAttributedString(string: L10n.Player.auto)
        let selected = selectedTitle.hasPrefix(autoTitle.string)
        items.insert(.checkmark(title: autoTitle, selected: selected), at: 0)
        return items
    }

    // MARK: - Init

    init(source: VideoQualitySource) {
        self.source = source
    }
}
