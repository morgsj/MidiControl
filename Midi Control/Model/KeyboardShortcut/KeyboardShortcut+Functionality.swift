//
//  KeyboardShortcut.swift
//  Midi Control
//
//  Created by Morgan Jones on 13/03/2021.
//

import Foundation
import Cocoa
import Carbon

extension KeyboardShortcut {
    
    func execute() {
        print("EXECUTE")
        
        let src = CGEventSource(stateID: CGEventSourceStateID.hidSystemState)
        
        let shiftd = CGEvent(keyboardEventSource: src, virtualKey: CGKeyCode(kVK_Shift), keyDown: true)
        let shiftu = CGEvent(keyboardEventSource: src, virtualKey: CGKeyCode(kVK_Shift), keyDown: false)
        
        let fnd = CGEvent(keyboardEventSource: src, virtualKey: CGKeyCode(kVK_Function), keyDown: true)
        let fnu = CGEvent(keyboardEventSource: src, virtualKey: CGKeyCode(kVK_Function), keyDown: false)
        
        let ctrld = CGEvent(keyboardEventSource: src, virtualKey: CGKeyCode(kVK_Control), keyDown: true)
        let ctrlu = CGEvent(keyboardEventSource: src, virtualKey: CGKeyCode(kVK_Control), keyDown: false)
        
        let optiond = CGEvent(keyboardEventSource: src, virtualKey: CGKeyCode(kVK_Option), keyDown: true)
        let optionu = CGEvent(keyboardEventSource: src, virtualKey: CGKeyCode(kVK_Option), keyDown: false)
        
        let cmdd = CGEvent(keyboardEventSource: src, virtualKey: CGKeyCode(kVK_Command), keyDown: true)
        let cmdu = CGEvent(keyboardEventSource: src, virtualKey: CGKeyCode(kVK_Command), keyDown: false)
        
        let keyd = CGEvent(keyboardEventSource: src, virtualKey: CGKeyCode(key), keyDown: true)
        let keyu = CGEvent(keyboardEventSource: src, virtualKey: CGKeyCode(key), keyDown: false)

        keyd?.flags = .maskControl
        keyu?.flags = .maskControl

        let loc = CGEventTapLocation.cghidEventTap

        if shift {shiftd?.post(tap: loc)}
        if fn {fnd?.post(tap: loc)}
        if ctrl {ctrld?.post(tap: loc)}
        if option {optiond?.post(tap: loc)}
        if cmd {cmdd?.post(tap: loc)}
        
        keyd?.post(tap: loc)
        keyu?.post(tap: loc)
        
        if shift {shiftu?.post(tap: loc)}
        if fn {fnu?.post(tap: loc)}
        if ctrl {ctrlu?.post(tap: loc)}
        if option {optionu?.post(tap: loc)}
        if cmd {cmdu?.post(tap: loc)}
        
    }
    
}

extension KeyboardShortcut {
    static func == (lhs: KeyboardShortcut, rhs: KeyboardShortcut) -> Bool {
        return lhs.shift == rhs.shift && lhs.fn == rhs.fn && lhs.ctrl == rhs.ctrl && lhs.cmd == rhs.cmd && lhs.option == rhs.option && lhs.key == rhs.key
    }

}
