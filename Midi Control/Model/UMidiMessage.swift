//
//  MidiMessage.swift
//  Midi Control
//
//  Created by Morgan Jones on 13/03/2021.
//

import CoreMIDI
import AudioKit

extension UMidiMessage {
    
    convenience init(channel: MIDIChannel, port: MIDIUniqueID, noteID: MIDIByte, value : MIDIByte) {
        self.init()
        self.channel = Int16(channel)
        self.port = port
        self.noteID = Int16(noteID)
        self.value = Int16(value)
    }
}
