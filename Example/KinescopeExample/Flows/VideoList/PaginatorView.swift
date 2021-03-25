//
//  PaginatorView.swift
//  KinescopeExample
//
//  Created by Никита Коробейников on 23.03.2021.
//

import UIKit
import protocol ReactiveDataDisplayManager.ProgressDisplayableItem

final class PaginatorView: UIView {

    private lazy var indicator = UIActivityIndicatorView(style: .gray)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupInitialState()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupInitialState()
    }

    private func setupInitialState() {
        backgroundColor = .clear
        addActvityIndicator()
    }

    private func addActvityIndicator() {
        addSubview(indicator)
        indicator.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }
}

// MARK: - ProgressDisplayableItem

extension PaginatorView: ProgressDisplayableItem {

    func showProgress(_ isLoading: Bool) {
        isLoading ? indicator.startAnimating() : indicator.stopAnimating()
    }

}
