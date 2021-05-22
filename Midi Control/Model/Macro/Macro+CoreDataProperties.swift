//
//  Macro+CoreDataProperties.swift
//  Midi Control
//
//  Created by Morgan Jones on 17/05/2021.
//
//

import Foundation
import CoreData


extension Macro {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Macro> {
        return NSFetchRequest<Macro>(entityName: "Macro")
    }

    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var enabled: Bool
    @NSManaged public var response: NSOrderedSet
    @NSManaged public var trigger: NSOrderedSet

}

// MARK: Generated accessors for response
extension Macro {

    @objc(insertObject:inResponseAtIndex:)
    @NSManaged public func insertIntoResponse(_ value: KeyboardShortcut, at idx: Int)

    @objc(removeObjectFromResponseAtIndex:)
    @NSManaged public func removeFromResponse(at idx: Int)

    @objc(insertResponse:atIndexes:)
    @NSManaged public func insertIntoResponse(_ values: [KeyboardShortcut], at indexes: NSIndexSet)

    @objc(removeResponseAtIndexes:)
    @NSManaged public func removeFromResponse(at indexes: NSIndexSet)

    @objc(replaceObjectInResponseAtIndex:withObject:)
    @NSManaged public func replaceResponse(at idx: Int, with value: KeyboardShortcut)

    @objc(replaceResponseAtIndexes:withResponse:)
    @NSManaged public func replaceResponse(at indexes: NSIndexSet, with values: [KeyboardShortcut])

    @objc(addResponseObject:)
    @NSManaged public func addToResponse(_ value: KeyboardShortcut)

    @objc(removeResponseObject:)
    @NSManaged public func removeFromResponse(_ value: KeyboardShortcut)

    @objc(addResponse:)
    @NSManaged public func addToResponse(_ values: NSOrderedSet)

    @objc(removeResponse:)
    @NSManaged public func removeFromResponse(_ values: NSOrderedSet)

}

// MARK: Generated accessors for trigger
extension Macro {

    @objc(insertObject:inTriggerAtIndex:)
    @NSManaged public func insertIntoTrigger(_ value: UMidiMessage, at idx: Int)

    @objc(removeObjectFromTriggerAtIndex:)
    @NSManaged public func removeFromTrigger(at idx: Int)

    @objc(insertTrigger:atIndexes:)
    @NSManaged public func insertIntoTrigger(_ values: [UMidiMessage], at indexes: NSIndexSet)

    @objc(removeTriggerAtIndexes:)
    @NSManaged public func removeFromTrigger(at indexes: NSIndexSet)

    @objc(replaceObjectInTriggerAtIndex:withObject:)
    @NSManaged public func replaceTrigger(at idx: Int, with value: UMidiMessage)

    @objc(replaceTriggerAtIndexes:withTrigger:)
    @NSManaged public func replaceTrigger(at indexes: NSIndexSet, with values: [UMidiMessage])

    @objc(addTriggerObject:)
    @NSManaged public func addToTrigger(_ value: UMidiMessage)

    @objc(removeTriggerObject:)
    @NSManaged public func removeFromTrigger(_ value: UMidiMessage)

    @objc(addTrigger:)
    @NSManaged public func addToTrigger(_ values: NSOrderedSet)

    @objc(removeTrigger:)
    @NSManaged public func removeFromTrigger(_ values: NSOrderedSet)

}

extension Macro : Identifiable {

}
