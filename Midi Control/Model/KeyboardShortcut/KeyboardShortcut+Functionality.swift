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

        print(key == kVK_ANSI_4)
        
        var flags: [CGEventFlags] = []
        if shift {flags.append(CGEventFlags.maskShift)}
        if fn {flags.append(CGEventFlags.maskSecondaryFn)}
        if ctrl {flags.append(CGEventFlags.maskControl)}
        if option {flags.append(CGEventFlags.maskAlternate)}
        if cmd {flags.append(CGEventFlags.maskCommand)}
        
        keyu?.flags = CGEventFlags(flags)
        keyd?.flags = CGEventFlags(flags)
        
        
        let loc = CGEventTapLocation.cghidEventTap
        
        keyd?.post(tap: loc)
        keyu?.post(tap: loc)
    }
    
}

extension KeyboardShortcut {
    static func == (lhs: KeyboardShortcut, rhs: KeyboardShortcut) -> Bool {
        return lhs.shift == rhs.shift && lhs.fn == rhs.fn && lhs.ctrl == rhs.ctrl && lhs.cmd == rhs.cmd && lhs.option == rhs.option && lhs.key == rhs.key
    }

}
