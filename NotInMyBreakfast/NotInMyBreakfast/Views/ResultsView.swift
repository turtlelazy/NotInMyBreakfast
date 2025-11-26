//
//  ResultsView.swift
//  NotInMyBreakfast
//
//  Created by Ishraq Mahid on 11/17/25.
//

import Foundation
import SwiftUI
import UIKit

// Uses centralized `Models/IngredientCatalog.swift` when available.

struct ResultsView: View {
    private let details: ProductDetails
    private let productImage: UIImage?
    @EnvironmentObject var blacklistStore: BlacklistStore
    @State private var showCatalogPicker: Bool = false

    // Accept ProductDetails directly
    init(product: ProductDetails, image: UIImage? = nil) {
        self.details = product
        self.productImage = image
    }

    // Accept the API wrapper Product and extract details safely
    init(product: Product, image: UIImage? = nil) {
        self.details = product.product ?? ProductDetails(productName: nil, ingredientsText: nil, ingredients: nil, imageUrl: nil)
        self.productImage = image
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Product: \(details.productName ?? "Unknown")")
                .font(.headline)

            // Product image (if available) — prefer the image passed from the scanner/picker
            if let img = productImage {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                    .cornerRadius(8)
                    .shadow(radius: 4)
            } else if let imageUrlString = details.imageUrl, let url = URL(string: imageUrlString) {
                // Prefer API-provided image when available
                if #available(iOS 15.0, *) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(height: 200)
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(height: 200)
                                .cornerRadius(8)
                                .shadow(radius: 4)
                        case .failure:
                            Rectangle()
                                .fill(Color.secondary.opacity(0.12))
                                .frame(height: 200)
                                .cornerRadius(8)
                                .overlay(Image(systemName: "photo").font(.largeTitle).foregroundColor(.secondary))
                        @unknown default:
                            EmptyView()
                        }
                    }
                } else {
                    // Fallback: show placeholder when AsyncImage isn't available
                    Rectangle()
                        .fill(Color.secondary.opacity(0.12))
                        .frame(height: 200)
                        .cornerRadius(8)
                        .overlay(
                            VStack {
                                Image(systemName: "photo")
                                    .font(.largeTitle)
                                    .foregroundColor(.secondary)
                                Text("No product image")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        )
                }
            } else {
                // Placeholder when no image is available
                Rectangle()
                    .fill(Color.secondary.opacity(0.12))
                    .frame(height: 200)
                    .cornerRadius(8)
                    .overlay(
                        VStack {
                            Image(systemName: "photo")
                                .font(.largeTitle)
                                .foregroundColor(.secondary)
                            Text("No product image")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    )
            }

            // Use shared blacklist store to find matches (only show blacklisted items)
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
            IngredientCatalogPicker(catalog: productCatalog(), onAdd: { selections in
                for s in selections { blacklistStore.add(s) }
                showCatalogPicker = false
            })
            .environmentObject(blacklistStore)
        }
    }

    // Build a catalog from the product's API ingredient list if available,
    // otherwise fall back to the bundled/global catalog.
    private func productCatalog() -> [String] {
        guard let ingredients = details.ingredients, !ingredients.isEmpty else {
            return IngredientCatalog.load()
        }

        let texts = ingredients.compactMap { $0.text?.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        var seen = Set<String>()
        var ordered: [String] = []
        for s in texts {
            let key = s.lowercased()
            if !seen.contains(key) {
                seen.insert(key)
                ordered.append(s)
            }
        }

        return ordered.sorted { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending }
    }
}

private struct IngredientCatalogPicker: View {
    @Environment(\.presentationMode) private var presentation
    @EnvironmentObject var blacklistStore: BlacklistStore
    @State private var search: String = ""
    @State private var selected: Set<String> = []

    var catalog: [String]
    var onAdd: ([String]) -> Void

    private var filtered: [String] {
        let source = catalog
        if search.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return source
        }
        return source.filter { $0.localizedCaseInsensitiveContains(search) }
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
