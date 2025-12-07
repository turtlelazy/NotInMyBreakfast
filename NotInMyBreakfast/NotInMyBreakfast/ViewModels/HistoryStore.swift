//
//  HistoryStore.swift
//  NotInMyBreakfast
//
//  Observable store for scan history persisted with @AppStorage
//

import Foundation
import Combine
import SwiftUI

final class HistoryStore: ObservableObject {
    @AppStorage("scan_history_v1") private var itemsData: Data = Data()
    
    @Published var items: [HistoryItem] = [] {
        didSet { save() }
    }
    
    init() {
        load()
    }
    
    func addScan(barcode: String, productName: String, hadBlacklistedIngredients: Bool, blacklistedIngredients: [String] = []) {
        let item = HistoryItem(
            barcode: barcode,
            productName: productName,
            hadBlacklistedIngredients: hadBlacklistedIngredients,
            blacklistedIngredients: blacklistedIngredients
        )
        // Add to beginning of array (most recent first)
        items.insert(item, at: 0)
        
        // Optionally limit history size (e.g., keep only last 100 items)
        if items.count > 100 {
            items = Array(items.prefix(100))
        }
    }
    
    func remove(at index: Int) {
        guard items.indices.contains(index) else { return }
        items.remove(at: index)
    }
    
    func removeAll() {
        items.removeAll()
    }
    
    private func load() {
        if !itemsData.isEmpty,
           let decoded = try? JSONDecoder().decode([HistoryItem].self, from: itemsData) {
            self.items = decoded
        }
    }
    
    private func save() {
        if let data = try? JSONEncoder().encode(items) {
            itemsData = data
        }
    }
}
