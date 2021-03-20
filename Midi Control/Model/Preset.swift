//
//  Preset.swift
//  Midi Control
//
//  Created by Morgan Jones on 11/03/2021.
//

class Preset {
    
    var name : String
    var state : Int?
    var connection : Connection?
    
    var isEnabled : Bool = false
    
    var macros : [Macro]
    
    init(name: String) { 
        self.name = name
        macros = []
    }
    
    init(name: String, connection: Connection) {
        self.name = name
        macros = []
        self.connection = connection
    }
    
    func addMacro(_ m : Macro) {
        macros.append(m)
    }
    
    func received(message : UMidiMessage) {
        for macro in macros {
            if macro.matches(message) {macro.execute()}
        }
    }
}

extension Preset : Equatable {
    static func == (lhs: Preset, rhs: Preset) -> Bool {
            return
                lhs.name == rhs.name &&
                lhs.state == rhs.state &&
                lhs.connection == rhs.connection &&
                lhs.isEnabled == rhs.isEnabled &&
                lhs.macros == rhs.macros
    }
}
