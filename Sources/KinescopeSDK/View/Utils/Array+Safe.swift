//
//  Array+Safe.swift
//  KinescopeSDK
//
//  Created by Никита Гагаринов on 08.04.2021.
//

import Foundation

extension Array {

    subscript (safe index: Int) -> Element? {
        return indices ~= index ? self[index] : nil
    }

}
