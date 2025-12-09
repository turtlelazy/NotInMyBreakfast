//
//  ResultsView.swift
//  NotInMyBreakfast
//
//  Created by Ishraq Mahid on 11/17/25.
//

import Foundation
import SwiftUI
import UIKit

struct ResultsView: View {
    private let details: ProductDetails
    private let productImage: UIImage?
    @EnvironmentObject var blacklistStore: BlacklistStore
    @EnvironmentObject var themeManager: ThemeManager
    @State private var showCatalogPicker: Bool = false

    init(product: ProductDetails, image: UIImage? = nil) {
        self.details = product
        self.productImage = image
    }

    init(product: Product, image: UIImage? = nil) {
        self.details = product.product ?? ProductDetails(productName: nil, ingredientsText: nil, ingredients: nil, imageUrl: nil)
        self.productImage = image
    }

    var body: some View {
        ZStack {
            themeManager.backgroundColor
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    // Product image - responsive height
                    productImageView()
                        .frame(height: 200)
                        .frame(maxWidth: .infinity)
                        .cornerRadius(20)
                        .shadow(color: Color.black.opacity(0.15), radius: 12, x: 0, y: 6)
                    
                    // Product info
                    VStack(alignment: .leading, spacing: 12) {
                        Text(details.productName ?? "Unknown Product")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(themeManager.textColor)
                        
                        if let text = details.ingredientsText {
                            Text(text)
                                .font(.system(size: 11, weight: .regular))
                                .foregroundColor(themeManager.secondaryTextColor)
                                .lineLimit(2)
                        }
                    }
                    .modernCard(theme: themeManager)
                    
                    // Ingredients check result
                    ingredientsCheckView()
                    
                    // All ingredients
                    allIngredientsView()
                    
                    // Add to blacklist button
                    Button(action: { showCatalogPicker = true }) {
                        HStack(spacing: 8) {
                            Image(systemName: "plus.circle.fill")
                            Text("Add More to Blacklist")
                        }
                    }
                    .gradientButton(theme: themeManager)
                    
                    Spacer()
                        .frame(height: 5)
                }
                .padding(12)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showCatalogPicker) {
            IngredientCatalogPicker(theme: themeManager, catalog: productCatalog(), onAdd: { selections in
                for s in selections { blacklistStore.add(s) }
                showCatalogPicker = false
            })
            .environmentObject(blacklistStore)
        }
    }
    
    // MARK: - Helper Views
    
    @ViewBuilder
    private func ingredientsCheckView() -> some View {
        let matchedIngredients = details.ingredients?.filter { ingredient in
            guard let text = ingredient.text else { return false }
            return blacklistStore.items.contains { text.localizedCaseInsensitiveContains($0) }
        } ?? []
        
        if !matchedIngredients.isEmpty {
            VStack(spacing: 10) {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(themeManager.warningColor)
                    Text("Blacklisted Ingredients Found")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(themeManager.textColor)
                }
                
                VStack(spacing: 6) {
                    ForEach(matchedIngredients, id: \.id) { ingredient in
                        HStack {
                            Circle()
                                .fill(themeManager.warningColor)
                                .frame(width: 5, height: 5)
                            Text(ingredient.text ?? "")
                                .font(.system(size: 12, weight: .regular))
                                .foregroundColor(themeManager.textColor)
                            Spacer()
                        }
                    }
                }
            }
            .padding(12)
            .background(themeManager.warningColor.opacity(0.08))
            .cornerRadius(16)
            .border(themeManager.warningColor.opacity(0.3), width: 1)
        } else {
            VStack(spacing: 8) {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(themeManager.successColor)
                    Text("Safe Product")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(themeManager.textColor)
                }
                Text("No blacklisted ingredients detected")
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(themeManager.secondaryTextColor)
            }
            .padding(12)
            .background(themeManager.successColor.opacity(0.08))
            .cornerRadius(16)
            .border(themeManager.successColor.opacity(0.3), width: 1)
        }
    }
    
    @ViewBuilder
    private func allIngredientsView() -> some View {
        if let ingredients = details.ingredients, !ingredients.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                Text("All Ingredients")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(themeManager.textColor)
                
                VStack(spacing: 4) {
                    ForEach(ingredients.prefix(10), id: \.id) { ingredient in
                        HStack {
                            Text(ingredient.text ?? "Unknown")
                                .font(.system(size: 12, weight: .regular))
                                .foregroundColor(themeManager.secondaryTextColor)
                            Spacer()
                        }
                    }
                    if ingredients.count > 10 {
                        Text("... and \(ingredients.count - 10) more")
                            .font(.system(size: 11, weight: .regular))
                            .foregroundColor(themeManager.secondaryTextColor)
                            .italic()
                    }
                }
            }
            .modernCard(theme: themeManager)
        }
    }
    
    @ViewBuilder
    private func productImageView() -> some View {
        if let img = productImage {
            Image(uiImage: img)
                .resizable()
                .scaledToFill()
        } else if let imageUrlString = details.imageUrl, let url = URL(string: imageUrlString) {
            if #available(iOS 15.0, *) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ZStack {
                            themeManager.cardBackgroundColor
                            ProgressView()
                        }
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure:
                        ZStack {
                            themeManager.cardBackgroundColor
                            Image(systemName: "photo")
                                .font(.system(size: 48))
                                .foregroundColor(themeManager.secondaryTextColor)
                        }
                    @unknown default:
                        ZStack {
                            themeManager.cardBackgroundColor
                        }
                    }
                }
            } else {
                ZStack {
                    themeManager.cardBackgroundColor
                    Image(systemName: "photo")
                        .font(.system(size: 48))
                        .foregroundColor(themeManager.secondaryTextColor)
                }
            }
        } else {
            ZStack {
                themeManager.cardBackgroundColor
                Image(systemName: "photo")
                    .font(.system(size: 48))
                    .foregroundColor(themeManager.secondaryTextColor)
            }
        }
    }

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
    @ObservedObject var theme: ThemeManager
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
        ZStack {
            theme.backgroundColor
                .ignoresSafeArea()
            
            VStack {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(theme.secondaryTextColor)
                    TextField("Search", text: $search)
                        .foregroundColor(theme.textColor)
                }
                .padding(12)
                .background(theme.secondaryColor)
                .cornerRadius(12)
                .padding()

                List(filtered, id: \.self) { item in
                    Button(action: {
                        if selected.contains(item) { selected.remove(item) }
                        else { selected.insert(item) }
                    }) {
                        HStack {
                            Text(item)
                                .foregroundColor(theme.textColor)
                            Spacer()
                            if selected.contains(item) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(theme.primaryColor)
                            }
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .background(theme.backgroundColor)
                
                HStack(spacing: 12) {
                    Button(action: { presentation.wrappedValue.dismiss() }) {
                        Text("Cancel")
                            .frame(maxWidth: .infinity)
                            .padding(12)
                            .background(theme.secondaryColor)
                            .cornerRadius(12)
                            .foregroundColor(theme.textColor)
                    }
                    
                    Button(action: {
                        onAdd(Array(selected))
                    }) {
                        Text("Add Selected")
                            .frame(maxWidth: .infinity)
                    }
                    .gradientButton(theme: theme)
                    .disabled(selected.isEmpty)
                }
                .padding()
            }
        }
    }
}
