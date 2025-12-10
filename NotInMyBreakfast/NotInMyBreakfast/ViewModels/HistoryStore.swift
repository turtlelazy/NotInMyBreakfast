//
//  HistoryStore.swift
//  NotInMyBreakfast
//
//  Observable store for scan history persisted with CoreData
//

import Foundation
import Combine
import SwiftUI
import CoreData

final class HistoryStore: ObservableObject {
    @Published var items: [HistoryItem] = []
    
    private let context: NSManagedObjectContext
    private let persistenceController: PersistenceController
    
    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext,
         persistenceController: PersistenceController = PersistenceController.shared) {
        self.context = context
        self.persistenceController = persistenceController
        load()
    }
    
    func addScan(barcode: String, productName: String, hadBlacklistedIngredients: Bool, blacklistedIngredients: [String] = []) {
        let entity = HistoryEntity(
            context: context,
            barcode: barcode,
            productName: productName,
            hadBlacklistedIngredients: hadBlacklistedIngredients,
            blacklistedIngredients: blacklistedIngredients
        )
        
        persistenceController.save(context: context)
        
        // Convert to HistoryItem and add to beginning (most recent first)
        let item = HistoryItem(
            id: entity.id,
            barcode: entity.barcode,
            productName: entity.productName,
            timestamp: entity.timestamp,
            hadBlacklistedIngredients: entity.hadBlacklistedIngredients,
            blacklistedIngredients: entity.blacklistedIngredients
        )
        items.insert(item, at: 0)
        
        // Optionally limit history size (e.g., keep only last 100 items)
        if items.count > 100 {
            items = Array(items.prefix(100))
            deleteOldestItems()
        }
        debugPrintCount()
    }
    
    func remove(at index: Int) {
        guard items.indices.contains(index) else { return }
        let item = items[index]
        
        // Delete from CoreData
        let request = HistoryEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", item.id as CVarArg)
        
        if let results = try? context.fetch(request), let entity = results.first {
            context.delete(entity)
            persistenceController.save(context: context)
        }
        
        items.remove(at: index)
    }
    
    func removeAll() {
        let request = HistoryEntity.fetchRequest()
        
        if let results = try? context.fetch(request) {
            for entity in results {
                context.delete(entity)
            }
            persistenceController.save(context: context)
        }
        
        items.removeAll()
    }
    
    private func load() {
        let request = HistoryEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \HistoryEntity.timestamp, ascending: false)]
        
        if let results = try? context.fetch(request) {
            items = results.map { entity in
                HistoryItem(
                    id: entity.id,
                    barcode: entity.barcode,
                    productName: entity.productName,
                    timestamp: entity.timestamp,
                    hadBlacklistedIngredients: entity.hadBlacklistedIngredients,
                    blacklistedIngredients: entity.blacklistedIngredients
                )
            }
        }
    }
    func debugPrintCount() {
        let request = HistoryEntity.fetchRequest()
        if let count = try? context.count(for: request) {
            print("History count:", count)
        }
    }

    private func deleteOldestItems() {
        let request = HistoryEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \HistoryEntity.timestamp, ascending: true)]
        request.fetchLimit = items.count - 100
        
        if let results = try? context.fetch(request) {
            for entity in results {
                context.delete(entity)
            }
            persistenceController.save(context: context)
        }
    }
}
