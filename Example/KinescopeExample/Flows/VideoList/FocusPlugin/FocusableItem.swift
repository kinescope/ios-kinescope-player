//
//  FocusableItem.swift
//  KinescopeExample
//
//  Created by Никита Коробейников on 24.03.2021.
//

protocol FocusableItem: class {

    var isFocused: Bool { get set }

    func focusUpdated(isFocused: Bool)

}
