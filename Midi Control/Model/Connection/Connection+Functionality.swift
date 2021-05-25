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
    
    /* This dictionary contains all the active connections */
    static var activeConnections : [MIDIUniqueID : Connection] = [:]
    
    static func populateConnections(context: NSManagedObjectContext) {
        
        // First we get all the connections from the data model
        do {Connection.connections = try context.fetch(Connection.fetchRequest())} catch {fatalError("Couldn't fetch forgotten devices: \(error)")}
        
        // Now we get all of the active connections
        let inputNames : [String] = AppDelegate.midi.inputNames
        let inputUIDs : [MIDIUniqueID] = AppDelegate.midi.inputUIDs
        
        print(inputNames)
        print(inputUIDs)
        
        Connection.activeConnections = [:]
        for i in 0..<inputNames.count {
            var connection = getConnection(inputNames[i], inputUIDs[i])
            if connection == nil {
                connection = Connection(context: context)
                connection!.connected = true
                connection!.id = inputUIDs[i]
                connection!.name = inputNames[i]
                connection!.visible = true
                connection!.forgotten = false
                
                //print("\nappending \(connection!)")
                Connection.connections.append(connection!)
                
            } else {
                if connection!.forgotten {print("FORGOTTEN"); continue}
                connection!.connected = true
            }
            
            Connection.activeConnections[connection!.id] = connection!
        }
        
        // We set the `connected` properties of all the connections, and remove it if it has been forgotten
        for connection in Connection.connections {
            if connection.forgotten {Connection.connections.removeAll(where: {$0 == connection})}
            connection.connected = (Connection.activeConnections[connection.id] != nil)
        }
    
        
        // Save the data
        do {
            try context.save()
            print("\nSaved preset\n")
        }
        catch {print("\n\(error)\n")}
    }
    
    private static func getConnection(_ name: String, _ UID: MIDIUniqueID) -> Connection? {
        for c in Connection.connections {
            if c.name == name && c.id == UID {return c}
        }
        return nil
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
            else if (u.connected && !v.connected) {return true}
            else if (v.connected && !u.connected) {return false}
            else {return u.name! < v.name!}
        }
    }
    
    static func getVisibleConnections() -> [Connection] {
        sortConnections()
        var i = 0
        while (i < connections.count && connections[i].visible) {i += 1}
        return Array(connections[0..<i])
    }
    
    static func ==(u: Connection, v: Connection) -> Bool {
        return u.id == v.id && u.connected == v.connected && u.name == v.name && u.visible == v.visible && u.presets == v.presets
    }
    
}

