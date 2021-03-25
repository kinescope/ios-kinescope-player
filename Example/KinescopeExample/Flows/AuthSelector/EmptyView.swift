//
//  EmptyView.swift
//  KinescopeExample
//
//  Created by Никита Коробейников on 25.03.2021.
//

import UIKit

@IBDesignable
final class EmptyView: UIView {

    // MARK: - Properties

    private var label = UILabel()

    @IBInspectable var text: String? {
        didSet {
            label.text = text
        }
    }

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupInitialState()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupInitialState()
    }

}

// MARK: - Private

private extension EmptyView {

    func setupInitialState() {
        backgroundColor = .white
        addLabel()
        configureLabel()
    }

    func addLabel() {
        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            label.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    func configureLabel() {
        label.font = .systemFont(ofSize: 24, weight: .medium)
        label.textColor = .black
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
    }

}
