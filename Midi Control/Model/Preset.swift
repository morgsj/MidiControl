//
//  Preset.swift
//  Midi Control
//
//  Created by Morgan Jones on 11/03/2021.
//
import Foundation

class Preset : NSObject {
    
    var name : String
    var connection : Connection?
    var isEnabled : Bool = false
    var macros : [Macro]
    
    init(name: String) {
        self.name = name
        macros = []
        
        super.init()
        UserDefaults.standard.set(self, forKey: "Preset")
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
    
    //MARK: Coder
    // https://stackoverflow.com/questions/19720611/attempt-to-set-a-non-property-list-object-as-an-nsuserdefaults
    
    required init(coder aDecoder: NSCoder) {
        name = aDecoder.decodeObject(forKey: "name") as! String
        //connection = (aDecoder.decodeObject(forKey: "connection") as! Connection)
        isEnabled = aDecoder.decodeObject(forKey: "enabled") as! Bool
        //macros = aDecoder.decodeObject(forKey: "enabled") as! [Macro]
        
        macros = []
    }

    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encode(name, forKey: "name")
        //aCoder.encode(connection, forKey: "connection")
        aCoder.encode(isEnabled, forKey: "isEnabled")
        //aCoder.encode(macros, forKey: "macros")
    }
    
    static let UserDefaultsPresetsKey = "presetsKey"
    
    static func archivePresets(presets: [Preset]) -> Data {
        do {
            let archivedObject = try NSKeyedArchiver.archivedData(withRootObject: presets as NSArray, requiringSecureCoding: true)
            return archivedObject
        } catch {fatalError("Unable to archive presets")}
    }
    
    static func retrievePeople() -> [Preset]? {
        
        if let unarchivedObject = UserDefaults.standard.object(forKey: UserDefaultsPresetsKey) as? Data {
            return NSKeyedUnarchiver.unarchivedObject(ofClasses: [Preset], from: unarchivedObject) as! [Preset]?
        }
        return nil
    }
}

//extension Preset : Equatable {
//    static func == (lhs: Preset, rhs: Preset) -> Bool {
//            return
//                lhs.name == rhs.name &&
//                lhs.connection == rhs.connection &&
//                lhs.isEnabled == rhs.isEnabled &&
//                lhs.macros == rhs.macros
//    }
//}
