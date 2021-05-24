//
//  UIActivityIndicator+KinescopeActivityIndicating.swift
//  KinescopeSDK
//
//  Created by Никита Коробейников on 30.03.2021.
//

import UIKit

extension UIActivityIndicatorView: KinescopeActivityIndicating {

    func showLoading(_ isLoading: Bool) {
        if isLoading {
            isHidden = false
            startAnimating()
        } else {
            stopAnimating()
            isHidden = true
        }
    }

}
