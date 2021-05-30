//
//  KeyboardShortcut+CoreDataProperties.swift
//  Midi Control
//
//  Created by Morgan Jones on 17/05/2021.
//
//

import Foundation
import CoreData


extension KeyboardShortcut {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<KeyboardShortcut> {
        return NSFetchRequest<KeyboardShortcut>(entityName: "KeyboardShortcut")
    }

    @NSManaged public var shift, fn, ctrl, option, cmd: Bool
    @NSManaged public var key: Int16

}

extension KeyboardShortcut : Identifiable {

}
