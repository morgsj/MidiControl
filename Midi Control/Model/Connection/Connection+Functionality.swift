//
//  Device.swift
//  Midi Control
//
//  Created by Morgan Jones on 11/03/2021.
//

import Foundation
import CoreData
import Cocoa

import CoreMIDI
import AudioKit

extension Connection {
    
    convenience init(name: String, id: MIDIUniqueID, port: MIDIPortRef) {
        self.init()
        self.name = name
        self.id = id
        self.port = Int32(port)
    }
    
    func shallowCopy(connection: Connection) {
        self.name = connection.name
        self.id = connection.id
        self.connected = connection.connected
        self.port = connection.port
        self.visible = connection.visible
        self.presets = connection.presets
    }
    
}

// MARK: Static Connection functionality

extension Connection {
    
    /*
     This contains all the connections that have ever been made (and saved into the data model).
     We keep track of this since presets may be made for devices that are not available all the time.
     */
    static var connections : [Connection] = []
    
    /* This dictionary contains all the active connections */
    static var activeConnections : [MIDIUniqueID : Connection] = [:]
    
    static func populateConnections(context: NSManagedObjectContext) {
        // First we get all the connections from the data model
        Connection.connections = []
        do {Connection.connections = try context.fetch(Connection.fetchRequest()) as! [Connection]}
        catch {fatalError("Could not get connections from data model")}
        
        // Now we get all of the active connections
        let inputNames : [String] = AppDelegate.midi.inputNames
        let inputUIDs : [MIDIUniqueID] = AppDelegate.midi.inputUIDs
        let inputPorts : [MIDIUniqueID : MIDIPortRef] = AppDelegate.midi.inputPorts
        
        Connection.activeConnections = [:]
        
        for i in 0..<inputNames.count {
            let connection = Connection(name: inputNames[i], id: inputUIDs[i], port: inputPorts[inputUIDs[i]]!)
            Connection.activeConnections[inputUIDs[i]] = connection
            
            // If we have never seen this connection before, add it to the data model
            if !Connection.connections.contains(connection) {
                // We have to build a new connection to set the context
                let newConnection = Connection(context: context)
                newConnection.shallowCopy(connection: connection)
                
            }
        }
        
        // Finally, we set the `connected` properties of all the connections
        for connection in Connection.connections {
            connection.connected = (Connection.activeConnections[connection.id] != nil)
        }
        
        
        // Save the data
        do {
            try context.save()
            print("\nSaved preset\n")
        }
        catch {print("\n\(error)\n")}
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
    
    static func ==(u: Connection, v: Connection) -> Bool {
        return u.id == v.id && u.connected == v.connected && u.name == v.name && u.port == v.port && u.visible == v.visible && u.presets == v.presets
    }
    
}

