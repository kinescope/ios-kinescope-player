//
//  ConstraintHelper.swift
//  KinescopeSDK
//
//  Created by Никита Коробейников on 25.03.2021.
//

import UIKit

extension UIView {

    func stretch(view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: topAnchor),
            view.leadingAnchor.constraint(equalTo: leadingAnchor),
            view.trailingAnchor.constraint(equalTo: trailingAnchor),
            view.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    func centerChild(view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.centerXAnchor.constraint(equalTo: centerXAnchor),
            view.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    func leftCenterChild(view: UIView, padding: CGFloat = 24.0) {
        view.translatesAutoresizingMaskIntoConstraints = false
        let xConstraint = NSLayoutConstraint(item: view,
                                             attribute: .centerX,
                                             relatedBy: .equal,
                                             toItem: self,
                                             attribute: .centerX,
                                             multiplier: 0.5,
                                             constant: -padding)
        NSLayoutConstraint.activate([
            xConstraint,
            view.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    func rightCenterChild(view: UIView, padding: CGFloat = 24.0) {
        view.translatesAutoresizingMaskIntoConstraints = false
        let xConstraint = NSLayoutConstraint(item: view,
                                             attribute: .centerX,
                                             relatedBy: .equal,
                                             toItem: self,
                                             attribute: .centerX,
                                             multiplier: 1.5,
                                             constant: +padding)
        NSLayoutConstraint.activate([
            xConstraint,
            view.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    func bottomChild(view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: leadingAnchor),
            view.trailingAnchor.constraint(equalTo: trailingAnchor),
            view.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    func bottomChildWithSafeArea(view: UIView) {
        let bottomAnchor: NSLayoutYAxisAnchor
        if #available(iOS 11.0, *) {
            bottomAnchor = safeAreaLayoutGuide.bottomAnchor
        } else {
            bottomAnchor = self.bottomAnchor
        }

        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: leadingAnchor),
            view.trailingAnchor.constraint(equalTo: trailingAnchor),
            view.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    func topChild(view: UIView, padding: CGFloat = 16.0) {
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: topAnchor, constant: padding),
            view.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            view.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding)
        ])
    }

    func topChildWithSafeArea(view: UIView, padding: CGFloat = 16.0) {
        let topAnchor: NSLayoutYAxisAnchor
        let leadingAnchor: NSLayoutXAxisAnchor
        let trailingAnchor: NSLayoutXAxisAnchor
        if #available(iOS 11.0, *) {
            topAnchor = safeAreaLayoutGuide.topAnchor
            leadingAnchor = safeAreaLayoutGuide.leadingAnchor
            trailingAnchor = safeAreaLayoutGuide.trailingAnchor
        } else {
            topAnchor = self.topAnchor
            leadingAnchor = self.leadingAnchor
            trailingAnchor = self.trailingAnchor
        }

        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: topAnchor, constant: padding),
            view.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            view.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding)
        ])
    }

    func topTrailingChildWithSafeArea(view: UIView, padding: CGFloat = 16.0) {
        let topAnchor: NSLayoutYAxisAnchor
        let leadingAnchor: NSLayoutXAxisAnchor
        let trailingAnchor: NSLayoutXAxisAnchor
        if #available(iOS 11.0, *) {
            topAnchor = safeAreaLayoutGuide.topAnchor
            leadingAnchor = safeAreaLayoutGuide.leadingAnchor
            trailingAnchor = safeAreaLayoutGuide.trailingAnchor
        } else {
            topAnchor = self.topAnchor
            leadingAnchor = self.leadingAnchor
            trailingAnchor = self.trailingAnchor
        }

        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: topAnchor, constant: padding),
            view.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding)
        ])
    }

    func squareSize(with side: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: side),
            heightAnchor.constraint(equalToConstant: side)
        ])
    }

}
