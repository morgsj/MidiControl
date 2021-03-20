//
//  Device.swift
//  Midi Control
//
//  Created by Morgan Jones on 11/03/2021.
//

import Foundation

class Connection {

    var name : String
    var enabled : Bool = true
    var connected : Bool = false
    
    init(name: String) {
        self.name = name
    }
    
}

// MARK: static connection functionality

extension Connection {
    
    static var connections : [Connection] = [Connection(name: "Device1"), Connection(name: "Device2"), Connection(name: "Device3")]
    
    static func connectionNames() -> [String] {
        var connectionNames : [String] = []
        
        for connection in connections {
            connectionNames.append(connection.name)
        }
        
        return connectionNames
    }
    
    static func sortConnections() {
        connections.sort { (u, v) -> Bool in
            if      (u.enabled && !v.enabled) {return true}
            else if (v.enabled && !u.enabled) {return false}
            else if (u.connected && !v.connected) {return true}
            else if (v.connected && !u.connected) {return false}
            else {return u.name < v.name}
        }
    }
    
    static func getVisibleConnections() -> [Connection] {
        sortConnections()
        var i = 0
        while (i < connections.count && connections[i].enabled) {i += 1}
        return Array(connections[0..<i])
        
    }
}

extension Connection : Equatable {
    // TODO: sort this out
    static func ==(lhs: Connection, rhs: Connection) -> Bool {
        return lhs.name == rhs.name
    }
}
