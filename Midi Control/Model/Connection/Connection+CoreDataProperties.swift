//
//  Connection+CoreDataProperties.swift
//  Midi Control
//
//  Created by Morgan Jones on 21/05/2021.
//
//

import Foundation
import CoreData


extension Connection {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Connection> {
        return NSFetchRequest<Connection>(entityName: "Connection")
    }

    @NSManaged public var connected: Bool
    @NSManaged public var id: Int32
    @NSManaged public var name: String?
    @NSManaged public var visible: Bool
    @NSManaged public var presets: NSSet?

}

// MARK: Generated accessors for presets
extension Connection {

    @objc(addPresetsObject:)
    @NSManaged public func addToPresets(_ value: Preset)

    @objc(removePresetsObject:)
    @NSManaged public func removeFromPresets(_ value: Preset)

    @objc(addPresets:)
    @NSManaged public func addToPresets(_ values: NSSet)

    @objc(removePresets:)
    @NSManaged public func removeFromPresets(_ values: NSSet)

}

extension Connection : Identifiable {

}
