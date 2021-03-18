//
//  KeyboardShortcut.swift
//  Midi Control
//
//  Created by Morgan Jones on 13/03/2021.
//

import Foundation

struct KeyboardShortcut {
    
    var keys : [CGKeyCode]
    
    func execute() {
//        let src = CGEventSourceCreate(CGEventSourceStateID(kCGEventSourceStateHIDSystemState)).takeRetainedValue()
//
//        let cmdd = CGEventCreateKeyboardEvent(src, 0x38, true).takeRetainedValue()
//        let cmdu = CGEventCreateKeyboardEvent(src, 0x38, false).takeRetainedValue()
//        let spcd = CGEventCreateKeyboardEvent(src, 0x31, true).takeRetainedValue()
//        let spcu = CGEventCreateKeyboardEvent(src, 0x31, false).takeRetainedValue()
//
//        CGEventSetFlags(spcd, CGEventFlags(kCGEventFlagMaskCommand));
//        CGEventSetFlags(spcd, CGEventFlags(kCGEventFlagMaskCommand));
//
//        let loc = CGEventTapLocation(rawValue: kCGHIDEventTap)
//
//        CGEventPost(loc, cmdd)
//        CGEventPost(loc, spcd)
//        CGEventPost(loc, spcu)
//        CGEventPost(loc, cmdu)
    }
    
}
