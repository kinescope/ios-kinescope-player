//
//  VideoListFocusableCellGenerator.swift
//  KinescopeExample
//
//  Created by Никита Коробейников on 24.03.2021.
//

import ReactiveDataDisplayManager

final class VideoListFocusableCellGenerator: FocusableItem, SelectableItem {

    // MARK: - Properties

    var didSelectEvent = BaseEvent<Void>()
    var uuid: String = ""
    var isFocused = false
    private weak var cell: VideoListCell?

    private var model: VideoListCell.Model

    // MARK: - Initialization

    init(video: VideoListCell.Model) {
        self.model = video
    }

    // MARK: - FocusableItem

    func focusUpdated(isFocused: Bool) {
        self.isFocused = isFocused
        self.updateCell(isFocused: isFocused)
    }
    
}

// MARK: - TableCellGenerator

extension VideoListFocusableCellGenerator: TableCellGenerator {
    
    var identifier: String {
        String(describing: VideoListCell.self)
    }

    func generate(tableView: UITableView, for indexPath: IndexPath) -> UITableViewCell {
        guard let cell = VideoListCell.loadFromNib() as? VideoListCell else {
            return UITableViewCell()
        }
        cell.configure(with: model)
        uuid = model.id
        updateCell(isFocused: isFocused)
        self.cell = cell
        return cell
    }

    func registerCell(in tableView: UITableView) {
        tableView.register(UINib(nibName: identifier.nameOfClass, bundle: Bundle(for: VideoListCell.self)),
                           forCellReuseIdentifier: identifier.nameOfClass)
    }

    var cellHeight: CGFloat {
        VideoListCell.height
    }

    var estimatedCellHeight: CGFloat? {
        VideoListCell.height
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
