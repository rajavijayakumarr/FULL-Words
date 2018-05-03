//
//  WordDetails+CoreDataProperties.swift
//  
//
//  Created by User on 03/05/18.
//
//

import Foundation
import CoreData


extension WordDetails {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WordDetails> {
        return NSFetchRequest<WordDetails>(entityName: "WordDetails")
    }

    @NSManaged public var nameOfWord: String?
    @NSManaged public var sourceOfWord: String?
    @NSManaged public var meaningOfWord: String?
    @NSManaged public var dateAdded: NSDate?
    @NSManaged public var wordAddedBy: String?

}
