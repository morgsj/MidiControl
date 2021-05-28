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
    static var visibleConnections : [Connection] = []
    
    /* This dictionary contains all the active connections */
    static var activeConnections : [MIDIUniqueID : Connection] = [:]
    
    static func populateConnections(context: NSManagedObjectContext) {
        
        // First we get all the connections from the data model
        do {Connection.connections = try context.fetch(Connection.fetchRequest())} catch {fatalError("Couldn't fetch forgotten devices: \(error)")}
        
        for connection in Connection.connections {
            connection.connected = false
        }
        
        // Now we get all of the active connections
        let inputNames : [String] = AppDelegate.midi.inputNames
        let inputUIDs : [MIDIUniqueID] = AppDelegate.midi.inputUIDs
        
        print(inputNames)
        print(inputUIDs)
        
        Connection.activeConnections = [:]
        for i in 0..<inputNames.count {
            var connection = getConnection(inputNames[i], inputUIDs[i])
            if connection == nil {
                // Create new connection for this device
                connection = Connection(context: context)
                connection!.connected = true
                connection!.id = inputUIDs[i]
                connection!.name = inputNames[i]
                connection!.visible = true
                connection!.forgotten = false
                
                Connection.connections.append(connection!)
                
            } else {
                if connection!.forgotten {continue}
                connection!.connected = true
            }
            
            Connection.activeConnections[connection!.id] = connection!
        }
        
        // We set the `connected` properties of all the connections, and remove it if it has been forgotten
        for connection in Connection.connections {
            if connection.forgotten {
                
                // TODO: Remove duplicates
//                matches = Connection.connections.filter(where: {$0 == connection})
//                if matches.count > 1 {
//                    for i in 1..<matches.count {
//                        do {try context.delete(matches[i])} catch {fatalError()}
//                    }
//                }
                
                Connection.connections.removeAll(where: {$0 == connection})
            } else {
                if connection.visible {Connection.visibleConnections.append(connection)}
            }
            
            connection.connected = (Connection.activeConnections[connection.id] != nil)
            
        }
        
        // Save the data
        do {try context.save()} catch {fatalError("\nCouldn't save: \(error)")}
    }
    
    private static func getConnection(_ name: String, _ UID: MIDIUniqueID) -> Connection? {
        for c in Connection.connections {
            if c.name == name && c.id == UID {return c}
        }
        return nil
    }
    
    static func ==(u: Connection, v: Connection) -> Bool {
        return u.id == v.id && u.connected == v.connected && u.name == v.name && u.visible == v.visible && u.presets == v.presets
    }
    
}

