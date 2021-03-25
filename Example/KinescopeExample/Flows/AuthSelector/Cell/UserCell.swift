//
//  UserCell.swift
//  KinescopeExample
//
//  Created by Никита Коробейников on 25.03.2021.
//

import ReactiveDataDisplayManager

final class UserCell: UITableViewCell {

    // MARK: - IBOutlets

    @IBOutlet private weak var label: UILabel!

    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .white
    }


}

// MARK: - ConfigurableItem

extension UserCell: ConfigurableItem {

    typealias Model = User

    func configure(with model: User) {
        label.text = model.name
    }
}
