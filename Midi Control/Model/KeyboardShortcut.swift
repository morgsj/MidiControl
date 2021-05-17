//
//  KeyboardShortcut.swift
//  Midi Control
//
//  Created by Morgan Jones on 13/03/2021.
//

import Foundation

extension KeyboardShortcut {
    func execute() {
        
    }
    
}

extension KeyboardShortcut {
    static func == (lhs: KeyboardShortcut, rhs: KeyboardShortcut) -> Bool {
        return lhs.keyCodes == rhs.keyCodes
    }
}
