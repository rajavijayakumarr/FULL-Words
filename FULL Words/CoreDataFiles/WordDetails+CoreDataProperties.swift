//
//  WordDetails+CoreDataProperties.swift
//  
//
//  Created by User on 17/05/18.
//
//

import Foundation
import CoreData


extension WordDetails {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WordDetails> {
        return NSFetchRequest<WordDetails>(entityName: "WordDetails")
    }

    @NSManaged public var dateAdded: Double
    @NSManaged public var dateUpdated: Double
    @NSManaged public var meaningOfWord: String?
    @NSManaged public var nameOfWord: String?
    @NSManaged public var sourceOfWord: String?
    @NSManaged public var wordAddedBy: String?
    @NSManaged public var userId: String?

}
