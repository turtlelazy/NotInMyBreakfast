//
//  HistoryStore.swift
//  NotInMyBreakfast
//
//  Observable store for scan history persisted to UserDefaults
//

import Foundation
import Combine

final class HistoryStore: ObservableObject {
    @Published var items: [HistoryItem] = [] {
        didSet { save() }
    }
    
    private let defaultsKey = "scan_history_v1"
    
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
        if let data = UserDefaults.standard.data(forKey: defaultsKey),
           let decoded = try? JSONDecoder().decode([HistoryItem].self, from: data) {
            self.items = decoded
        }
    }
    
    private func save() {
        if let data = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(data, forKey: defaultsKey)
        }
    }
}
