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
    
    convenience init(name: String, id: MIDIUniqueID) {
        self.init()
        self.name = name
        self.id = id
    }
    
    func shallowCopy(connection: Connection) {
        self.name = connection.name
        self.id = connection.id
        self.connected = connection.connected
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
    
    static func refreshConnections(context: NSManagedObjectContext, shouldFetch: Bool) {
        
        // First we get all the connections from the data model
        if shouldFetch {Connection.connections = try! context.fetch(Connection.fetchRequest())}
        
        // Assume all the connections in the database are not connected
        for connection in Connection.connections {
            connection.connected = false
        }
        
        // Now we build the dictionary of active connections
        let inputNames : [String] = AppDelegate.midi.inputNames
        let inputUIDs : [MIDIUniqueID] = AppDelegate.midi.inputUIDs
        
        Connection.activeConnections = [:]
        for i in 0..<inputNames.count {
            
            // For each connected device, see if we have seen it before
            var connection = getConnection(inputNames[i], inputUIDs[i])
            if connection == nil {
                // Create new connection for this device
                connection = Connection(context: context)
                connection!.connected = true
                connection!.id = inputUIDs[i]
                connection!.name = inputNames[i]
                connection!.forgotten = false
                
                Connection.connections.append(connection!)
                
            } else {
                if connection!.forgotten {continue}
                connection!.connected = true
            }
            
            Connection.activeConnections[connection!.id] = connection!
        }
    
        // Save the data
        try! context.save()
        
        
    }
    
    private static func getConnection(_ name: String, _ UID: MIDIUniqueID) -> Connection? {
        for c in Connection.connections {
            if c.name == name && c.id == UID {return c}
        }
        return nil
    }
    
    static func connectionWhitelist() -> [Connection] {
        return Connection.connections.filter({!$0.forgotten})
    }
    
    static func ==(u: Connection, v: Connection) -> Bool {
        return u.id == v.id && u.connected == v.connected && u.name == v.name && u.forgotten == v.forgotten && u.presets == v.presets
    }
    
}

