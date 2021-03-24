//
//  CurrentCellFocusPlugin.swift
//  KinescopeExample
//
//  Created by Никита Коробейников on 24.03.2021.
//

import ReactiveDataDisplayManager

/// Plugin to Detect Most Visible Cell in `UITableView`
final class CurrentCellFocusPlugin: PluginAction {

    // MARK: - Alias

    typealias GeneratorType = FocusableItem

    typealias Event = ScrollEvent
    typealias Manager = BaseTableManager

    // MARK: - Properties

    weak var focusedGenerator: GeneratorType?

    // MARK: - Public Methods

    func setup(with manager: BaseTableManager?) {
        focusedGenerator = nil
    }

    func process(event: ScrollEvent, with manager: BaseTableManager?) {

        switch event {
        case .didScroll:

            guard let visiblePaths = manager?.view.indexPathsForVisibleRows,
                  !visiblePaths.isEmpty else {
                return
            }

            let firstVisiblePath = visiblePaths[0]
            let newFocusedGenerator = getGenerator(from: manager, at: firstVisiblePath)

            if let oldFocusedGenerator = focusedGenerator,
               !(oldFocusedGenerator === newFocusedGenerator) {
                print("KIN stop")
                oldFocusedGenerator.focusUpdated(isFocused: false)
            }

            focusedGenerator = newFocusedGenerator
            focusedGenerator?.focusUpdated(isFocused: true)
            print("KIN start")

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

// MARK: - Public init

extension BaseTablePlugin {

    static func currentFocus() -> CurrentCellFocusPlugin {
        .init()
    }

}
