//
//  IngredientCatalog.swift
//  NotInMyBreakfast
//
//  Predefined list of common ingredient names that align with typical API outputs
//

import Foundation

/// IngredientCatalog loads a more comprehensive ingredient list from a bundled JSON file
/// named `ingredients.json` (an array of strings). If the bundle file isn't present
/// the catalog falls back to the built-in compact list. Use `IngredientCatalog.load()`
/// to retrieve the list.
struct IngredientCatalog {
    private static let fallback: [String] = [
        "Sugar", "Salt", "Palm Oil", "Soy", "Soya Lecithin", "Peanuts", "Peanut",
        "Milk", "Whey", "Casein", "Egg", "Gelatin", "Wheat", "Barley",
        "Rye", "Oats", "Gluten", "Almonds", "Cashews", "Hazelnuts", "Tree Nuts",
        "Sesame", "Mustard", "Celery", "Fish", "Crustaceans", "Molluscs", "Lupin",
        "Sulphites", "Citric Acid", "Natural Flavour", "Artificial Flavour", "Corn",
        "Starch", "Soy Lecithin", "Monosodium Glutamate", "MSG", "Hydrogenated Vegetable Oil",
        "Vegetable Oil", "Palm Kernel Oil", "Canola", "Rapeseed", "Beef", "Pork",
        "Chicken", "Fish Oil"
    ]

    /// Load catalog from bundle `ingredients.json` if present, otherwise return fallback.
    /// The result is normalized by trimming whitespace and removing empty strings,
    /// and sorted for predictable display.
    static func load() -> [String] {
        // try bundle resource
        if let url = Bundle.main.url(forResource: "ingredients", withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let decoded = try? JSONDecoder().decode([String].self, from: data) {
            return normalize(decoded)
        }

        return normalize(fallback)
    }

    private static func normalize(_ items: [String]) -> [String] {
        let cleaned = items.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        // Use case-insensitive unique set while preserving original casing of first occurrence
        var seen = Set<String>()
        var ordered: [String] = []
        for s in cleaned {
            let key = s.lowercased()
            if !seen.contains(key) {
                seen.insert(key)
                ordered.append(s)
            }
        }
        return ordered.sorted { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending }
    }
}
