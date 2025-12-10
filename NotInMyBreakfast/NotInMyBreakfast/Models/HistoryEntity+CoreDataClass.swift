//
//  HistoryEntity+CoreDataClass.swift
//  NotInMyBreakfast
//
//  Created by Ishraq Mahid on 12/10/25.
//

import Foundation
import CoreData

@objc(HistoryEntity)
public class HistoryEntity: NSManagedObject {}

extension HistoryEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<HistoryEntity> {
        return NSFetchRequest<HistoryEntity>(entityName: "HistoryEntity")
    }

    @NSManaged public var id: UUID
    @NSManaged public var barcode: String
    @NSManaged public var productName: String
    @NSManaged public var hadBlacklistedIngredients: Bool
    @NSManaged public var blacklistedIngredientsData: Data?
    @NSManaged public var timestamp: Date
}

// convenience computed property to read/write the array
extension HistoryEntity {
    var blacklistedIngredients: [String] {
        get {
            guard let data = blacklistedIngredientsData else { return [] }
            return (try? JSONDecoder().decode([String].self, from: data)) ?? []
        }
        set {
            blacklistedIngredientsData = try? JSONEncoder().encode(newValue)
        }
    }

    // convenience initializer
    convenience init(context: NSManagedObjectContext,
                     id: UUID = UUID(),
                     barcode: String,
                     productName: String,
                     hadBlacklistedIngredients: Bool,
                     blacklistedIngredients: [String] = [],
                     timestamp: Date = Date()) {
        self.init(context: context)
        self.id = id
        self.barcode = barcode
        self.productName = productName
        self.hadBlacklistedIngredients = hadBlacklistedIngredients
        self.blacklistedIngredients = blacklistedIngredients
        self.timestamp = timestamp
    }
}
