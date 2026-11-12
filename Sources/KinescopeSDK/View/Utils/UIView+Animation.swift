//
//  UIView+Animation.swift
//  KinescopeSDK
//
//  Created by Nikita Korobeinikov on 06.03.2024.
//

import UIKit

private var chromeAnimationGenerationKey: UInt8 = 0

extension UIView {

    /// A newer show or hide makes an in-flight completion a no-op.
    func invalidateAnimatedVisibility() {
        chromeAnimationGeneration += 1
    }

    func showAnimated(with completion: (() -> Void)? = nil) {
        let generation = chromeAnimationGeneration + 1
        chromeAnimationGeneration = generation
        self.isHidden = false
        self.isUserInteractionEnabled = true
        self.alpha = 0
        UIView.animate(withDuration: 0.2, animations: {
            self.alpha = 1
        }, completion: { _ in
            guard self.chromeAnimationGeneration == generation else {
                return
            }
            completion?()
        })
    }

    func hideAnimated(with completion: (() -> Void)? = nil) {
        let generation = chromeAnimationGeneration + 1
        chromeAnimationGeneration = generation
        UIView.animate(withDuration: 0.2, animations: {
            self.alpha = 0
        }, completion: { _ in
            guard self.chromeAnimationGeneration == generation else {
                return
            }
            self.isHidden = true
            self.isUserInteractionEnabled = false
            completion?()
        })
    }

    private var chromeAnimationGeneration: Int {
        get { objc_getAssociatedObject(self, &chromeAnimationGenerationKey) as? Int ?? 0 }
        set { objc_setAssociatedObject(self, &chromeAnimationGenerationKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
}
