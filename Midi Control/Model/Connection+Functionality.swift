//
//  Device.swift
//  Midi Control
//
//  Created by Morgan Jones on 11/03/2021.
//

import Foundation

import CoreMIDI
import AudioKit

extension Connection {
    
    convenience init(name: String, id: MIDIUniqueID, port: MIDIPortRef) {
        self.init()
        self.name = name
        self.id = id
        self.port = Int32(port)
    }
    
}

// MARK: Static Connection functionality

extension Connection {
    
    static var connections : [Connection] = []
    static var connectionDictionary : [MIDIUniqueID : Connection] = [:]
    
    static func populateConnections() {
        let inputNames : [String] = AppDelegate.midi.inputNames
        let inputUIDs : [MIDIUniqueID] = AppDelegate.midi.inputUIDs
        let inputPorts : [MIDIUniqueID : MIDIPortRef] = AppDelegate.midi.inputPorts
        
        Connection.connections = []
        Connection.connectionDictionary = [:]
        
        for i in 0..<inputNames.count {
            let newConnection = Connection(name: inputNames[i], id: inputUIDs[i], port: inputPorts[inputUIDs[i]]!)
            Connection.connections.append(newConnection)
            
            Connection.connectionDictionary[inputUIDs[i]] = Connection.connections.last
        }
    }
    
    static func connectionNames() -> [String] {
        var connectionNames : [String] = []
        
        for connection in connections {
            connectionNames.append(connection.name!)
        }
        
        return connectionNames
    }
    
    static func sortConnections() {
        connections.sort { (u, v) -> Bool in
            if      (u.visible && !v.visible) {return true}
            else if (v.visible && !u.visible) {return false}
            else if (u.isEnabled && !v.isEnabled) {return true}
            else if (v.isEnabled && !u.isEnabled) {return false}
            else {return u.name! < v.name!}
        }
    }
    
    static func getVisibleConnections() -> [Connection] {
        sortConnections()
        var i = 0
        while (i < connections.count && connections[i].visible) {i += 1}
        return Array(connections[0..<i])
    }
    
}

