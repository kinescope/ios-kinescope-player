//
//  NSObject.swift
//  KinescopeExample
//
//  Created by Никита Гагаринов on 30.04.2021.
//

import Foundation

extension NSObject {

    @objc class var nameOfClass: String {
        if let name = NSStringFromClass(self).components(separatedBy: ".").last {
            return name
        }
        return ""
    }

    @objc var nameOfClass: String {
        if let name = NSStringFromClass(type(of: self)).components(separatedBy: ".").last {
            return name
        }
        return ""
    }

}
