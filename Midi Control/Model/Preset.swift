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
    
    var isEnabled : Bool = true
    
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
