//
//  MidiMessage.swift
//  Midi Control
//
//  Created by Morgan Jones on 13/03/2021.
//

struct UMidiMessage {
    
    var statusByte : UInt8
    var dataByte1 : UInt8
    var dataByte2: UInt8
    
    init(message: UInt32) {
        dataByte2  = UInt8( message        & 0b11111111)
        dataByte1  = UInt8((message >> 8)  & 0b11111111)
        statusByte = UInt8((message >> 16) & 0b11111111)
    }
    
    func toString() -> String {
        let messageType = statusByte >> 4
        
        switch messageType {
            case 0x8:
                // Note off
                return "Note off | Note: " + String(dataByte1) + " | Velocity: " + String(dataByte2)
            case 0x9:
                // Note on
                return "Note on | Note: " + String(dataByte1) + " | Velocity: " + String(dataByte2)
            case 0xA:
                // Key pressure
                return "Key pressure | Note: " + String(dataByte1) + " | Pressure: " + String(dataByte2)
            case 0xB:
                // Control change
                return "Control change | Controller: " + String(dataByte1) + " | Value: " + String(dataByte2)
            case 0xC:
                // Program change
                return "Program change | Program: " + String(dataByte1)
            case 0xD:
                // Channel pressure
                return "Channel pressure | Pressure: " + String(dataByte1)
            case 0xE:
                // Pitch bend
                return "Pitch bend | Pressure: " + String(dataByte1 << 8 + dataByte2)
            default:
                return "Error"
            
        }
    }
    
    static func ==(lhs: UMidiMessage, rhs: UMidiMessage) -> Bool {
        return lhs.statusByte == rhs.statusByte && lhs.dataByte1 == rhs.dataByte1 && lhs.dataByte2 == rhs.dataByte2
    }
    
    static let NOTE_OFF : UInt8 = 0x8
    static let NOTE_ON : UInt8 = 0x9
    static let KEY_PRESSURE : UInt8 = 0xA
    static let CONTROL_CHANGE : UInt8 = 0xB
    static let PROGRAM_CHANGE : UInt8 = 0xC
    static let CHANNEL_PRESSURE : UInt8 = 0xD
    static let PITCH_BEND : UInt8 = 0xE
    
}
// https://users.cs.cf.ac.uk/Dave.Marshall/Multimedia/node158.html
