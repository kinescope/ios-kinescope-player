//
//  SideMenuItemsProvider.swift
//  KinescopeSDK
//
//  Created by Nikita Korobeinikov on 13.03.2024.
//

import Foundation

protocol SideMenuItemsProvider {
    var selectedTitle: String { get }
    var items: [SideMenu.Item] { get }
}
