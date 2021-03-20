//
//  Macro.swift
//  Midi Control
//
//  Created by Morgan Jones on 13/03/2021.
//

struct Macro {
    
    var triggers : [UMidiMessage]
    var response : [KeyboardShortcut]
    
    func matches(_ message : UMidiMessage) -> Bool {
        for trigger in triggers {
            if (message == trigger) {return true}
        }
        return false
    }
    
    func execute() {
        for shortcut in response {shortcut.execute()}
    }
    
}

extension Macro : Equatable {
    static func == (lhs: Macro, rhs: Macro) -> Bool {
        return lhs.triggers == rhs.triggers && lhs.response == rhs.response
    }
}
