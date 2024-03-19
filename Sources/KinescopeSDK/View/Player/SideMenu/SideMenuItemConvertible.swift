//
//  SideMenuItemConvertible.swift
//  KinescopeSDK
//
//  Created by Nikita Korobeinikov on 13.03.2024.
//

import Foundation

protocol SideMenuItemConvertible {
    func asSideMenuItem() -> SideMenu.Item
}
