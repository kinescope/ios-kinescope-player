//
//  CurrentCellFocusPlugin.swift
//  KinescopeExample
//
//  Created by Никита Коробейников on 24.03.2021.
//

import ReactiveDataDisplayManager

/// Plugin to Detect Most Visible Cell in `UITableView`
final class CurrentCellFocusPlugin: BaseTablePlugin<ScrollEvent> {

    // MARK: - Alias

    typealias GeneratorType = FocusableItem

    // MARK: - Properties

    weak var focusedGenerator: GeneratorType?

    // MARK: - Public Methods

    override func process(event: ScrollEvent, with manager: BaseTableManager?) {

        switch event {
        case .didScroll:

            guard let table = manager?.view,
                let firstVisibleCell = getFirstVisibleCell(from: table),
                let firstVisiblePath = table.indexPath(for: firstVisibleCell) else {
                return
            }

            let newFocusedGenerator = getGenerator(from: manager, at: firstVisiblePath)

            if let oldFocusedGenerator = focusedGenerator {
                if oldFocusedGenerator === newFocusedGenerator {

                } else {
                    oldFocusedGenerator.focusUpdated(isFocused: false)
                    focusedGenerator = newFocusedGenerator
                    focusedGenerator?.focusUpdated(isFocused: true)
                }

            } else {
                focusedGenerator = newFocusedGenerator
                focusedGenerator?.focusUpdated(isFocused: true)
            }

        default:
            break
        }

    }

}

// MARK: - Private

private extension CurrentCellFocusPlugin {

    func getGenerator(from manager: BaseTableManager?, at indexPath: IndexPath) -> GeneratorType? {
        guard let generator = manager?.generators[indexPath.section][indexPath.row] else {
            return nil
        }
        return generator as? GeneratorType
    }

    func getFirstVisibleCell(from table: UITableView) -> UITableViewCell? {
        let visibleY = table.contentOffset.y
        let visibleCells = table.visibleCells.filter { $0.frame.origin.y > visibleY }
        return visibleCells.min(by: { $0.frame.origin.y < $1.frame.origin.y })
    }

}

// MARK: - Public init

extension BaseTablePlugin {

    static func currentFocus() -> CurrentCellFocusPlugin {
        .init()
    }

}
