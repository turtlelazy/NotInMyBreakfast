//
//  BlacklistView.swift
//  NotInMyBreakfast
//
//  Created by Ishraq Mahid on 11/17/25.
//

import Foundation
import SwiftUI

struct BlacklistView: View {
    @State private var items: [String] = []
    @State private var newIngredient: String = ""
    @State private var showCatalogPicker: Bool = false
    @State private var showConfirmDeleteIndex: Int? = nil
    private let defaultsKey = "blacklist_items_v1"

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                TextField("Add ingredient", text: $newIngredient)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.words)
                Button(action: addIngredient) {
                    Text("Add")
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                Button(action: { showCatalogPicker = true }) {
                    Image(systemName: "plus.square.on.square")
                        .padding(8)
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(8)
                }
            }
            .padding()

            Divider()

            ScrollView {
                LazyVStack(alignment: .leading, spacing: 8, pinnedViews: []) {
                    ForEach(items.indices, id: \.self) { index in
                        let ingredient = items[index]
                        HStack {
                            Text(ingredient)
                                .padding(.vertical, 10)
                                .padding(.horizontal)
                                .background(Color(UIColor.secondarySystemBackground))
                                .cornerRadius(8)

                            Spacer()

                            Button(action: { showConfirmDeleteIndex = index }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                            .buttonStyle(BorderlessButtonStyle())
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
        }
        .navigationTitle("Blacklisted Ingredients")
        .alert("Remove Ingredient", isPresented: Binding(
            get: { showConfirmDeleteIndex != nil },
            set: { if !$0 { showConfirmDeleteIndex = nil } }
        ), presenting: showConfirmDeleteIndex) { idx in
            Button("Remove", role: .destructive) {
                if items.indices.contains(idx) {
                    items.remove(at: idx)
                    saveItems()
                }
                showConfirmDeleteIndex = nil
            }
            Button("Cancel", role: .cancel) {
                showConfirmDeleteIndex = nil
            }
        } message: { idx in
            Text("Remove \(items.indices.contains(idx) ? items[idx] : "this item") from blacklist?")
        }
        .onAppear(perform: loadItems)
        .sheet(isPresented: $showCatalogPicker) {
            CatalogPickerView(onAdd: { selections in
                for s in selections {
                    let trimmed = s.trimmingCharacters(in: .whitespacesAndNewlines)
                    if !trimmed.isEmpty && !items.contains(where: { $0.caseInsensitiveCompare(trimmed) == .orderedSame }) {
                        items.append(trimmed)
                    }
                }
                saveItems()
                showCatalogPicker = false
            })
        }
    }

    private func addIngredient() {
        let trimmed = newIngredient.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        // Avoid duplicates (case-insensitive)
        if !items.contains(where: { $0.caseInsensitiveCompare(trimmed) == .orderedSame }) {
            items.append(trimmed)
            saveItems()
        }
        newIngredient = ""
    }

    private func loadItems() {
        if let data = UserDefaults.standard.data(forKey: defaultsKey),
           let decoded = try? JSONDecoder().decode([String].self, from: data) {
            items = decoded
        } else {
            items = ["Gelatin", "Peanuts", "Palm Oil"]
            saveItems()
        }
    }

    private func saveItems() {
        if let data = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(data, forKey: defaultsKey)
        }
    }
}

// Simple local catalog & picker for adding ingredients from a predefined list
struct CatalogPickerView: View {
    @Environment(\.presentationMode) private var presentation
    @State private var search: String = ""
    @State private var selected: Set<String> = []

    var onAdd: ([String]) -> Void

    private var catalog: [String] = {
        // Try to load a bundled `ingredients.json` (array of strings). If the project
        // doesn't include `Models/IngredientCatalog.swift` in the target, this still
        // allows using a bundled JSON resource. Falls back to a compact built-in list.
        if let url = Bundle.main.url(forResource: "ingredients", withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let decoded = try? JSONDecoder().decode([String].self, from: data) {
            return decoded.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
                .reduce(into: [String]()) { acc, s in
                    if !acc.contains(where: { $0.caseInsensitiveCompare(s) == .orderedSame }) {
                        acc.append(s)
                    }
                }
                .sorted { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending }
        }

        return [
            "Sugar", "Salt", "Palm Oil", "Soy", "Soya Lecithin", "Peanuts", "Peanut",
            "Milk", "Whey", "Casein", "Egg", "Gelatin", "Wheat", "Barley",
            "Rye", "Oats", "Gluten", "Almonds", "Cashews", "Hazelnuts", "Tree Nuts",
            "Sesame", "Mustard", "Celery", "Fish", "Crustaceans", "Molluscs", "Lupin",
            "Sulphites", "Citric Acid", "Natural Flavour", "Artificial Flavour", "Corn",
            "Starch", "Soy Lecithin", "Monosodium Glutamate", "MSG", "Hydrogenated Vegetable Oil",
            "Vegetable Oil", "Palm Kernel Oil", "Canola", "Rapeseed", "Beef", "Pork",
            "Chicken", "Fish Oil"
        ]
    }()

    init(onAdd: @escaping ([String]) -> Void) {
        self.onAdd = onAdd
    }

    private var filtered: [String] {
        let term = search.trimmingCharacters(in: .whitespacesAndNewlines)
        if term.isEmpty { return catalog }
        return catalog.filter { $0.localizedCaseInsensitiveContains(term) }
    }

    var body: some View {
        NavigationView {
            VStack {
                TextField("Search catalog", text: $search)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                List(filtered, id: \.self) { item in
                    Button(action: {
                        if selected.contains(item) { selected.remove(item) }
                        else { selected.insert(item) }
                    }) {
                        HStack {
                            Text(item)
                            Spacer()
                            if selected.contains(item) { Image(systemName: "checkmark") }
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .navigationTitle("Add from Catalog")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { presentation.wrappedValue.dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add Selected") {
                        onAdd(Array(selected))
                    }
                    .disabled(selected.isEmpty)
                }
            }
        }
    }
}



