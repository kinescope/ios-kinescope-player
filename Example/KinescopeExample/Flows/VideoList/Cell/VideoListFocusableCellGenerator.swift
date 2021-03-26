//
//  VideoListFocusableCellGenerator.swift
//  KinescopeExample
//
//  Created by Никита Коробейников on 24.03.2021.
//

import ReactiveDataDisplayManager

final class VideoListFocusableCellGenerator: BaseCellGenerator<VideoListCell>, FocusableItem {

    // MARK: - Properties

    var isFocused = false

    weak var cell: VideoListCell?

    // MARK: - FocusableItem

    func focusUpdated(isFocused: Bool) {
        self.isFocused = isFocused
        self.updateCell(isFocused: isFocused)
    }

    // MARK: - Configure

    override func configure(cell: VideoListCell, with model: VideoListCell.Model) {
        super.configure(cell: cell, with: model)

        self.cell = cell
        self.updateCell(isFocused: isFocused)
    }

}

// MARK: - Private

private extension VideoListFocusableCellGenerator {

    func updateCell(isFocused: Bool) {
        if isFocused {
            cell?.start()
        } else {
            cell?.stop()
        }
    }

}
