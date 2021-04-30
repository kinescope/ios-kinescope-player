//
//  UIView.swift
//  KinescopeExample
//
//  Created by Никита Гагаринов on 30.04.2021.
//

import UIKit

extension UIView {

    static func loadFromNib<T: UIView>() -> T {
        let bundle = Bundle(for: self)
        let nibName = String(describing: self)
        let nib = UINib(nibName: nibName, bundle: bundle)

        guard let view = nib.instantiate(withOwner: self, options: nil).first as? T else {
            return T()
        }

        return view
    }

}
