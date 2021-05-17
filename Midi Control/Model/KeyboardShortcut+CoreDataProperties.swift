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

    @NSManaged public var keyCodes: NSObject?

}

extension KeyboardShortcut : Identifiable {

}
