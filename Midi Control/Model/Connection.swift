//
//  Device.swift
//  Midi Control
//
//  Created by Morgan Jones on 11/03/2021.
//

import Foundation

import CoreMIDI
import AudioKit

class Connection {
    
    var visible : Bool = true
    var connected : Bool = true
    
    var name : String
    var info : EndpointInfo
    var id : MIDIUniqueID
    var port : MIDIPortRef
    
    init(name: String, info: EndpointInfo, id: MIDIUniqueID, port: MIDIPortRef) {
        self.name = name
        self.info = info
        self.id = id
        self.port = port
    }
    
}

// MARK: Static Connection functionality

extension Connection {
    
    static var connections : [Connection] = []
    static var connectionDictionary : [MIDIUniqueID : Connection] = [:]
    
    static func populateConnections() {
        let inputNames : [String] = AppDelegate.midi.inputNames
        let inputInfos : [EndpointInfo] = AppDelegate.midi.inputInfos
        let inputUIDs : [MIDIUniqueID] = AppDelegate.midi.inputUIDs
        let inputPorts : [MIDIUniqueID : MIDIPortRef] = AppDelegate.midi.inputPorts
        
        Connection.connections = []
        Connection.connectionDictionary = [:]
        
        for i in 0..<inputNames.count {
            let newConnection = Connection(name: inputNames[i], info: inputInfos[i], id: inputUIDs[i], port: inputPorts[inputUIDs[i]]!)
            Connection.connections.append(newConnection)
            
            Connection.connectionDictionary[inputUIDs[i]] = Connection.connections.last
        }
    }
    
    static func connectionNames() -> [String] {
        var connectionNames : [String] = []
        
        for connection in connections {
            connectionNames.append(connection.name)
        }
        
        return connectionNames
    }
    
    static func sortConnections() {
        connections.sort { (u, v) -> Bool in
            if      (u.visible && !v.visible) {return true}
            else if (v.visible && !u.visible) {return false}
            else if (u.connected && !v.connected) {return true}
            else if (v.connected && !u.connected) {return false}
            else {return u.name < v.name}
        }
    }
    
    static func getVisibleConnections() -> [Connection] {
        sortConnections()
        var i = 0
        while (i < connections.count && connections[i].visible) {i += 1}
        return Array(connections[0..<i])
    }
    
}



extension Connection : Equatable {
    // TODO: sort this out
    static func ==(lhs: Connection, rhs: Connection) -> Bool {
        return lhs.name == rhs.name
    }
}
