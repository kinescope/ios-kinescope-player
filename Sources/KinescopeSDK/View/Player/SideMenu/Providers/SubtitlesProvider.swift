//
//  SubtitlesProvider.swift
//  KinescopeSDK
//
//  Created by Nikita Korobeinikov on 13.03.2024.
//

import AVFoundation

protocol SubtitlesSource: AnyObject {
    var currentSubtitles: String? { get }
    var availableSubtitles: [String] { get }
}

final class SubtitlesProvider: SideMenuItemsProvider {

    // MARK: - Properties

    private weak var source: SubtitlesSource?

    // MARK: - SideMenuItemsProvider

    var selectedTitle: String {
        source?.currentSubtitles ?? L10n.Player.off
    }

    var items: [SideMenu.Item] {
        let subtitles = source?.availableSubtitles ?? []
        var items = subtitles.compactMap { subtitle -> SideMenu.Item in
            let selected = self.selectedTitle.trimmingCharacters(in: .symbols) == subtitle
            return .checkmark(title: .init(string: subtitle), selected: selected)
        }

        let offTitle = NSAttributedString(string: L10n.Player.off)
        let selected = selectedTitle == offTitle.string
        items.insert(.checkmark(title: offTitle, selected: selected), at: 0)
        return items
    }

    // MARK: - Init

    init(source: SubtitlesSource) {
        self.source = source
    }
}
