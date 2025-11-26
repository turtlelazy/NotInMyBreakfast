//
//  ResultsView.swift
//  NotInMyBreakfast
//
//  Created by Ishraq Mahid on 11/17/25.
//

import Foundation
import SwiftUI

// Local ingredient catalog (keeps picker working even if separate catalog file isn't in the project)
private struct IngredientCatalog {
    static let all: [String] = [
        "Sugar",
        "Salt",
        "Palm Oil",
        "Soy",
        "Soya Lecithin",
        "Peanuts",
        "Peanut",
        "Milk",
        "Whey",
        "Casein",
        "Egg",
        "Gelatin",
        "Wheat",
        "Barley",
        "Rye",
        "Oats",
        "Gluten",
        "Almonds",
        "Cashews",
        "Hazelnuts",
        "Tree Nuts",
        "Sesame",
        "Mustard",
        "Celery",
        "Fish",
        "Crustaceans",
        "Molluscs",
        "Lupin",
        "Sulphites",
        "Citric Acid",
        "Natural Flavour",
        "Artificial Flavour",
        "Corn",
        "Starch",
        "Soy Lecithin",
        "Monosodium Glutamate",
        "MSG",
        "Hydrogenated Vegetable Oil",
        "Vegetable Oil",
        "Palm Kernel Oil",
        "Canola",
        "Rapeseed",
        "Beef",
        "Pork",
        "Chicken",
        "Fish Oil"
    ]
}

struct ResultsView: View {
    private let details: ProductDetails
    @EnvironmentObject var blacklistStore: BlacklistStore
    @State private var showCatalogPicker: Bool = false

    // Accept ProductDetails directly
    init(product: ProductDetails) {
        self.details = product
    }

    // Accept the API wrapper Product and extract details safely
    init(product: Product) {
        self.details = product.product ?? ProductDetails(productName: nil, ingredientsText: nil, ingredients: nil)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Product: \(details.productName ?? "Unknown")")
                .font(.headline)

            Text("Ingredients: \(details.ingredientsText ?? "N/A")")

            // Use shared blacklist store to find matches
            let matchedIngredients = details.ingredients?.filter { ingredient in
                guard let text = ingredient.text else { return false }
                return blacklistStore.items.contains { text.localizedCaseInsensitiveContains($0) }
            } ?? []

            if !matchedIngredients.isEmpty {
                Text("⚠️ Blacklisted Ingredients Found:")
                    .font(.headline)
                ForEach(matchedIngredients, id: \.id) { ingredient in
                    Text(ingredient.text ?? "")
                }
            } else {
                Text("✅ No blacklisted ingredients found")
            }

            Divider().padding(.vertical)

            Button(action: { showCatalogPicker = true }) {
                Label("Select Ingredients to Blacklist", systemImage: "plus.circle")
            }
            .padding(.top)

            Spacer()
        }
        .padding()
        .navigationTitle("Results")
        .sheet(isPresented: $showCatalogPicker) {
            IngredientCatalogPicker(onAdd: { selections in
                for s in selections { blacklistStore.add(s) }
                showCatalogPicker = false
            })
            .environmentObject(blacklistStore)
        }
    }
}

private struct IngredientCatalogPicker: View {
    @Environment(\.presentationMode) private var presentation
    @EnvironmentObject var blacklistStore: BlacklistStore
    @State private var search: String = ""
    @State private var selected: Set<String> = []

    var onAdd: ([String]) -> Void

    private var filtered: [String] {
        if search.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return IngredientCatalog.all
        }
        return IngredientCatalog.all.filter { $0.localizedCaseInsensitiveContains(search) }
    }

    var body: some View {
        NavigationView {
            VStack {
                TextField("Search ingredients", text: $search)
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
                            if selected.contains(item) {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .navigationTitle("Ingredient Catalog")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { presentation.wrappedValue.dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add Selected") {
                        let addList = Array(selected)
                        onAdd(addList)
                    }
                    .disabled(selected.isEmpty)
                }
            }
        }
    }
}
