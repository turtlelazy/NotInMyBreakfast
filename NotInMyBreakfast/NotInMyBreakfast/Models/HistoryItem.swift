//
//  HistoryItem.swift
//  NotInMyBreakfast
//
//  Model for storing scan history with product information
//

import Foundation

struct HistoryItem: Codable, Identifiable {
    let id: UUID
    let barcode: String
    let productName: String
    let timestamp: Date
    let hadBlacklistedIngredients: Bool
    let blacklistedIngredients: [String]
    
    init(id: UUID = UUID(), barcode: String, productName: String, timestamp: Date = Date(), hadBlacklistedIngredients: Bool, blacklistedIngredients: [String] = []) {
        self.id = id
        self.barcode = barcode
        self.productName = productName
        self.timestamp = timestamp
        self.hadBlacklistedIngredients = hadBlacklistedIngredients
        self.blacklistedIngredients = blacklistedIngredients
    }
}
