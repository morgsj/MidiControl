//
//  Preset+CoreDataProperties.swift
//  Midi Control
//
//  Created by Morgan Jones on 17/05/2021.
//
//

import Foundation
import CoreData


extension Preset {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Preset> {
        return NSFetchRequest<Preset>(entityName: "Preset")
    }

    @NSManaged public var isEnabled: Bool
    @NSManaged public var name: String?
    @NSManaged public var connection: Connection?
    @NSManaged public var macros: NSOrderedSet?

}

// MARK: Generated accessors for macros
extension Preset {

    @objc(insertObject:inMacrosAtIndex:)
    @NSManaged public func insertIntoMacros(_ value: Macro, at idx: Int)

    @objc(removeObjectFromMacrosAtIndex:)
    @NSManaged public func removeFromMacros(at idx: Int)

    @objc(insertMacros:atIndexes:)
    @NSManaged public func insertIntoMacros(_ values: [Macro], at indexes: NSIndexSet)

    @objc(removeMacrosAtIndexes:)
    @NSManaged public func removeFromMacros(at indexes: NSIndexSet)

    @objc(replaceObjectInMacrosAtIndex:withObject:)
    @NSManaged public func replaceMacros(at idx: Int, with value: Macro)

    @objc(replaceMacrosAtIndexes:withMacros:)
    @NSManaged public func replaceMacros(at indexes: NSIndexSet, with values: [Macro])

    @objc(addMacrosObject:)
    @NSManaged public func addToMacros(_ value: Macro)

    @objc(removeMacrosObject:)
    @NSManaged public func removeFromMacros(_ value: Macro)

    @objc(addMacros:)
    @NSManaged public func addToMacros(_ values: NSOrderedSet)

    @objc(removeMacros:)
    @NSManaged public func removeFromMacros(_ values: NSOrderedSet)

}

extension Preset : Identifiable {

}
