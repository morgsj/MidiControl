//
//  Device.swift
//  Midi Control
//
//  Created by Morgan Jones on 11/03/2021.
//

import Foundation

struct Connection {

    var name : String
    var enabled : Bool = true
    var connected : Bool = true
    
    static func ==(lhs: Connection, rhs: Connection) -> Bool {
        return lhs.name == rhs.name
    }
}

extension Connection {
    
    static var connections : [Connection] = [Connection(name: "Device1"), Connection(name: "Device2"), Connection(name: "Device3")]
    
    static func connectionNames() -> [String] {
        var connectionNames : [String] = []
        
        for connection in connections {
            connectionNames.append(connection.name)
        }
        
        return connectionNames
    }
}
