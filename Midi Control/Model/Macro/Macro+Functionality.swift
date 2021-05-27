//
//  Macro.swift
//  Midi Control
//
//  Created by Morgan Jones on 13/03/2021.
//

import Foundation
import AudioKit
import CoreMIDI

extension Macro {
    
    func matches(noteID: MIDIByte, value: MIDIByte, channel: MIDIChannel, type: Int) -> Bool {
        
        for trigger in self.triggers {
            guard let trigger = trigger as? UMidiMessage else {fatalError("Can't cast trigger to midi message")}
            
            if (trigger.messageType == type) && (trigger.noteID == noteID) && (trigger.ignoresChannel || trigger.channel == channel) {
                
                if trigger.messageType == UMidiMessage.MessageType.NoteOffMessage || trigger.messageType == UMidiMessage.MessageType.NoteOnMessage {
                    
                    if trigger.ignoresVelocity || trigger.value == value {
                        return true
                    }
                    
                } else {
                    if trigger.value == value  {
                        return true
                    }
                }
                
            }
        }
        
        return false
    }
    
    func execute() {
        for shortcut in response {(shortcut as! KeyboardShortcut).execute()}
    }
    
}

extension Macro {
    static func == (lhs: Macro, rhs: Macro) -> Bool {
        return lhs.triggers == rhs.triggers && lhs.response == rhs.response
    }
    
    static func === (lhs: Macro, rhs: Macro) -> Bool {
        return lhs.id == rhs.id
    }
}
