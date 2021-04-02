//
//  CurrentCellFocusPlugin.swift
//  KinescopeExample
//
//  Created by Никита Коробейников on 24.03.2021.
//

import ReactiveDataDisplayManager

public protocol CurrentCellFocusInput: class {

    func updateFocus()

    func clearFocus()
}

public protocol CurrentCellFocusOutput: class {

    func onFocusInitialized(with input: CurrentCellFocusInput)
}

/// Plugin to Detect Most Visible Cell in `UITableView`
final class CurrentCellFocusPlugin: BaseTablePlugin<ScrollEvent> {

    // MARK: - Alias

    typealias GeneratorType = FocusableItem

    // MARK: - Properties

    private weak var focusedGenerator: GeneratorType?

    private weak var manager: BaseTableManager?

    private weak var output: CurrentCellFocusOutput?

    private lazy var debouncer = Debouncer(queue: .global(qos: .userInteractive), delay: .milliseconds(500))

    // MARK: - Init

    init(output: CurrentCellFocusOutput) {
        self.output = output
    }

    // MARK: - Public Methods

    override func setup(with manager: BaseTableManager?) {
        self.manager = manager
        output?.onFocusInitialized(with: self)
    }

    override func process(event: ScrollEvent, with manager: BaseTableManager?) {

        switch event {
        case .didScroll:
            debouncer.run { [weak self] in
                DispatchQueue.main.async { [weak self] in
                    self?.updateFocus()
                }
            }
        default:
            break
        }

    }

}

// MARK: - CurrentCellFocusInput

extension CurrentCellFocusPlugin: CurrentCellFocusInput {

    func updateFocus() {
        guard let table = manager?.view,
            let firstVisibleCell = getFirstVisibleCell(from: table),
            let firstVisiblePath = table.indexPath(for: firstVisibleCell),
            let currentFocusedGenerator = getGenerator(from: manager, at: firstVisiblePath),
            let focused = compare(old: focusedGenerator, new: currentFocusedGenerator) else {
            return
        }

        focusedGenerator?.focusUpdated(isFocused: false)
        focusedGenerator = focused
        focused.focusUpdated(isFocused: true)
    }

    func clearFocus() {
        focusedGenerator?.focusUpdated(isFocused: false)
        focusedGenerator = nil
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

    func compare(old: FocusableItem?, new: FocusableItem) -> FocusableItem? {
        guard let old = old else {
            return new
        }
        return old.uuid == new.uuid ? nil : new
    }

}

// MARK: - Public init

extension BaseTablePlugin {

    static func currentFocus(output: CurrentCellFocusOutput) -> CurrentCellFocusPlugin {
        .init(output: output)
    }

}
