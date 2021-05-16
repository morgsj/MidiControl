//
//  MidiMessage.swift
//  Midi Control
//
//  Created by Morgan Jones on 13/03/2021.
//

import CoreMIDI
import AudioKit

class UMidiMessage {
    let channel: MIDIChannel
    let port: MIDIUniqueID
    
    init(channel: MIDIChannel, port: MIDIUniqueID) {
        self.channel = channel
        self.port = port
    }
}

class NoteOnMessage : UMidiMessage {
    let noteNumber : MIDINoteNumber
    let velocity : MIDIVelocity
    
    init(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel, port: MIDIUniqueID) {
        self.noteNumber = noteNumber
        self.velocity = velocity
        super.init(channel: channel, port: port)
    }
}

class NoteOffMessage : UMidiMessage {
    let noteNumber : MIDINoteNumber
    let velocity : MIDIVelocity
    
    init(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel, port: MIDIUniqueID) {
        self.noteNumber = noteNumber
        self.velocity = velocity
        super.init(channel: channel, port: port)
    }
}

class ControlMessage : UMidiMessage {
    let controller : MIDIByte
    let value : MIDIByte
    
    init(controller: MIDIByte, value: MIDIByte, channel: MIDIChannel, port: MIDIUniqueID) {
        self.controller = controller
        self.value = value
        super.init(channel: channel, port: port)
    }
}
