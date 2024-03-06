//
//  UIView+Animation.swift
//  KinescopeSDK
//
//  Created by Nikita Korobeinikov on 06.03.2024.
//

import UIKit

extension UIView {

    func showAnimated(with completion: (() -> Void)? = nil) {
        self.isHidden = false
        self.alpha = 0
        UIView.animate(withDuration: 0.2, animations: {
            self.alpha = 1
        }, completion: { _ in
            completion?()
        })
    }

    func hideAnimated(with completion: (() -> Void)? = nil) {
        self.alpha = 1
        UIView.animate(withDuration: 0.2, animations: {
            self.alpha = 0
        }, completion: { _ in
            self.isHidden = true
            completion?()
        })
    }
}
