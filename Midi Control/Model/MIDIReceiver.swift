//
//  MidiReceiver.swift
//  Midi Control
//
//  Created by Morgan Jones on 16/05/2021.
//

import Foundation
import Cocoa

import AudioKit
import CoreMIDI

class MIDIReceiver : MIDIListener {
    
    let context: NSManagedObjectContext
    
    typealias MIDIMessageTuple = (type: Int16, data1: Int16, data2: Int16, channel: Int16)
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func receivedMIDINoteOn(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel, portID: MIDIUniqueID?, timeStamp: MIDITimeStamp?) {
        
        if let macroEditor = PresetEditorView.macroEditor {
            if macroEditor.awaitingMidiInput && ViewController.PresetEditor!.preset?.connection?.id == portID {
                DispatchQueue.main.async {
                    macroEditor.newMidiInput = (UMidiMessage.MessageType.NoteOnMessage, Int16(noteNumber), Int16(velocity), Int16(channel))
                }
                
            }
        }
        
        if let portID = portID {
            
            if let connection = Connection.activeConnections[portID] {
                for preset in Preset.presets {
                    
                    if preset.connection == connection {
                        
                        for macro in preset.macros {
                            guard let macro = macro as? Macro else {fatalError("Couldn't cast to Macro")}
                            
                            if macro.matches(noteID: noteNumber, value: velocity, channel: channel, type: Int(UMidiMessage.MessageType.NoteOnMessage)) {
                                macro.execute()
                            }
                        }
                        
                    }
                    
                }
            }
            
            print(#function)
        }
    }
    
    func receivedMIDINoteOff(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel, portID: MIDIUniqueID?, timeStamp: MIDITimeStamp?) {
        
        if let macroEditor = PresetEditorView.macroEditor {
            if macroEditor.awaitingMidiInput {
                DispatchQueue.main.async {
                    macroEditor.newMidiInput = (UMidiMessage.MessageType.NoteOffMessage, Int16(noteNumber), Int16(velocity), Int16(channel))
                }
            }
        }
        
        if let portID = portID {
            
            if let connection = Connection.activeConnections[portID] {
                for preset in Preset.presets {
                    
                    if preset.connection == connection {
                        
                        for macro in preset.macros {
                            guard let macro = macro as? Macro else {fatalError("Couldn't cast to Macro")}
                            
                            if macro.matches(noteID: noteNumber, value: velocity, channel: channel, type: Int(UMidiMessage.MessageType.NoteOffMessage)) {
                                macro.execute()
                            }
                        }
                        
                    }
                    
                }
            }
            
            print(#function)
        }
    }
    
    func receivedMIDIController(_ controller: MIDIByte, value: MIDIByte, channel: MIDIChannel, portID: MIDIUniqueID?, timeStamp: MIDITimeStamp?) {
        
        if let macroEditor = PresetEditorView.macroEditor {
            if macroEditor.awaitingMidiInput {
                DispatchQueue.main.async {
                    macroEditor.newMidiInput = (UMidiMessage.MessageType.ControlMessage, Int16(controller), Int16(value), Int16(channel))
                }
            }
        }
        
        if let portID = portID {
            let message = UMidiMessage(context: context)
            message.messageType = UMidiMessage.MessageType.NoteOnMessage
            message.noteID = Int16(controller)
            message.value = Int16(value)
            message.channel = Int16(channel)
            message.port = portID
            
            print(#function)
        }
    }
    
    func receivedMIDIAftertouch(noteNumber: MIDINoteNumber, pressure: MIDIByte, channel: MIDIChannel, portID: MIDIUniqueID?, timeStamp: MIDITimeStamp?) {}
    func receivedMIDIAftertouch(_ pressure: MIDIByte, channel: MIDIChannel, portID: MIDIUniqueID?, timeStamp: MIDITimeStamp?) {}
    func receivedMIDIPitchWheel(_ pitchWheelValue: MIDIWord, channel: MIDIChannel, portID: MIDIUniqueID?, timeStamp: MIDITimeStamp?) {}
    func receivedMIDIProgramChange(_ program: MIDIByte, channel: MIDIChannel, portID: MIDIUniqueID?, timeStamp: MIDITimeStamp?) {}
    func receivedMIDISystemCommand(_ data: [MIDIByte], portID: MIDIUniqueID?, timeStamp: MIDITimeStamp?) {}
    func receivedMIDISetupChange() {}
    func receivedMIDIPropertyChange(propertyChangeInfo: MIDIObjectPropertyChangeNotification) {}
    func receivedMIDINotification(notification: MIDINotification) {}
}
