//
//  CurrentCellFocusPlugin.swift
//  KinescopeExample
//
//  Created by Никита Коробейников on 24.03.2021.
//

import ReactiveDataDisplayManager

/// Plugin to Detect Most Visible Cell in `UITableView`
final class CurrentCellFocusPlugin: BaseTablePlugin<TableEvent> {

    // MARK: - Alias

    typealias GeneratorType = FocusableItem

    // MARK: - Public Methods

    override func process(event: TableEvent, with manager: BaseTableManager?) {

        switch event {
        case .willDisplayCell(let indexPath):
            guard let focusable = getGenerator(from: manager, at: indexPath) else {
                return
            }

            // TODO: - calculate  percent of visibility
            focusable.focusUpdated(isFocused: true)
        case .didEndDisplayCell(let indexPath):
            guard let focusable = getGenerator(from: manager, at: indexPath) else {
                return
            }

            // TODO: - calculate  percent of visibility
            focusable.focusUpdated(isFocused: false)
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

}
