//
//  MidiMessage.swift
//  Midi Control
//
//  Created by Morgan Jones on 13/03/2021.
//

import CoreMIDI
import AudioKit

extension UMidiMessage {
    
     enum MessageType {
        static let NoteOnMessage: Int16 = 0
        static let NoteOffMessage: Int16 = 1
        static let ControlMessage: Int16 = 2
    }
    
    convenience init(messageType: Int16, noteID: MIDIByte, value: MIDIByte, channel: MIDIChannel, port: MIDIUniqueID) {
        self.init()
        self.channel = Int16(channel)
        self.port = port
        self.noteID = Int16(noteID)
        self.value = Int16(value)
        self.messageType = messageType
    }
}
