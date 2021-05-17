//
//  UMidiMessage+CoreDataProperties.swift
//  Midi Control
//
//  Created by Morgan Jones on 17/05/2021.
//
//

import Foundation
import CoreData


extension UMidiMessage {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UMidiMessage> {
        return NSFetchRequest<UMidiMessage>(entityName: "UMidiMessage")
    }

    @NSManaged public var channel: Int16
    @NSManaged public var noteID: Int16
    @NSManaged public var port: Int32
    @NSManaged public var value: Int16

}

extension UMidiMessage : Identifiable {

}
