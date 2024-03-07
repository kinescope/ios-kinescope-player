//
//  KinescopeVideo+Subtitles.swift
//  KinescopeSDK
//
//  Created by Nikita Korobeinikov on 20.02.2024.
//

import Foundation

extension KinescopeVideo {
    
    var allSubtitlesVariants: [String]? {
        subtitles?.compactMap { $0.title }
    }

    var hasSubtitles: Bool {
        !(subtitles?.isEmpty ?? true)
    }

    func firstSubtitle(by title: String) -> KinescopeVideoSubtitle? {
        subtitles?.first(where: { $0.title == title })
    }

    func hasSubtitle(with title: String) -> Bool {
        firstSubtitle(by: title) != nil
    }

}
