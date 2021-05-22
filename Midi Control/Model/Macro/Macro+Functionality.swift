//
//  Macro.swift
//  Midi Control
//
//  Created by Morgan Jones on 13/03/2021.
//

import Foundation

extension Macro {
    
    func matches(_ message : UMidiMessage) -> Bool {
//        for trigger in triggers {
//            if (message == trigger) {return true}
//        }
        return false
    }
    
    func execute() {
        for shortcut in response {(shortcut as! KeyboardShortcut).execute()}
    }
    
}

extension Macro {
    static func == (lhs: Macro, rhs: Macro) -> Bool {
        return true //lhs.triggers == rhs.triggers && lhs.response == rhs.response
    }
    
    static func === (lhs: Macro, rhs: Macro) -> Bool {
        return lhs.id == rhs.id
    }
}
