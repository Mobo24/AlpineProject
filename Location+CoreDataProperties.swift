//
//  Location+CoreDataProperties.swift
//  AlpineProject
//
//  Created by Mobolaji Moronfolu on 12/1/20.
//
//

import Foundation
import CoreData


extension Location {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Location> {
        return NSFetchRequest<Location>(entityName: "Location")
    }

    @NSManaged public var city: String?
    @NSManaged public var state: String?
    @NSManaged public var population: Int32
    @NSManaged public var longitude: Double
    @NSManaged public var latitude: Double

}

extension Location : Identifiable {

}
