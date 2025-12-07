//
//  BlacklistStore.swift
//  NotInMyBreakfast
//
//  Observable store for blacklisted ingredients persisted with @AppStorage
//

import Foundation
import Combine
import SwiftUI

final class BlacklistStore: ObservableObject {
    @AppStorage("blacklist_items_v1") private var itemsData: Data = Data()
    
    @Published var items: [String] = [] {
        didSet { save() }
    }

    init(defaults: [String] = ["Gelatin", "Peanuts", "Palm Oil"]) {
        // Load from AppStorage
        if !itemsData.isEmpty,
           let decoded = try? JSONDecoder().decode([String].self, from: itemsData) {
            self.items = decoded
        } else {
            self.items = defaults
            save()
        }
    }

    func add(_ ingredient: String) {
        let trimmed = ingredient.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        // Avoid duplicates (case-insensitive)
        if !items.contains(where: { $0.caseInsensitiveCompare(trimmed) == .orderedSame }) {
            items.append(trimmed)
        }
    }

    func remove(at index: Int) {
        guard items.indices.contains(index) else { return }
        items.remove(at: index)
    }

    func move(from source: IndexSet, to destination: Int) {
        items.move(fromOffsets: source, toOffset: destination)
    }

    private func save() {
        if let data = try? JSONEncoder().encode(items) {
            itemsData = data
        }
    }
}
