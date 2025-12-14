//
//  BlacklistView.swift
//  NotInMyBreakfast
//
//  Created by Ishraq Mahid on 11/17/25.
//

import Foundation
import SwiftUI
import BreakfastUIKit

struct BlacklistView: View {
    @EnvironmentObject var blacklistStore: BlacklistStore
    @EnvironmentObject var themeManager: ThemeManager
    @State private var newIngredient: String = ""
    @State private var showCatalogPicker: Bool = false
    @State private var showConfirmDeleteIndex: Int? = nil

    var body: some View {
        ZStack {
            themeManager.backgroundColor
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Manage Blacklist")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(themeManager.textColor)
                    Text("\(blacklistStore.items.count) ingredients")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(themeManager.secondaryTextColor)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                
                // Add ingredient section
                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        TextField("Add ingredient", text: $newIngredient)
                            .padding(12)
                            .background(themeManager.secondaryColor)
                            .cornerRadius(12)
                            .foregroundColor(themeManager.textColor)
                        
                        Button(action: addIngredient) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(themeManager.primaryColor)
                        }
                        
                        Button(action: { showCatalogPicker = true }) {
                            Image(systemName: "list.bullet.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(themeManager.accentColor)
                        }
                    }
                    .padding(16)
                    .background(themeManager.cardBackgroundColor)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 2)
                }
                .padding(16)
                
                // Ingredients list
                if blacklistStore.items.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 48))
                            .foregroundColor(themeManager.successColor)
                        Text("No ingredients blacklisted")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(themeManager.textColor)
                        Text("Add ingredients to avoid")
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(themeManager.secondaryTextColor)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(blacklistStore.items.indices, id: \.self) { index in
                                let ingredient = blacklistStore.items[index]
                                HStack(spacing: 12) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(ingredient)
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(themeManager.textColor)
                                    }
                                    
                                    Spacer()
                                    
                                    Button(action: { showConfirmDeleteIndex = index }) {
                                        Image(systemName: "trash.circle.fill")
                                            .font(.system(size: 20))
                                            .foregroundColor(themeManager.errorColor)
                                    }
                                }
                                .modernCard(theme: themeManager)
                            }
                            .onMove(perform: { source, destination in
                                blacklistStore.move(from: source, to: destination)
                            })
                        }
                        .padding(16)
                    }
                }
                
                Spacer()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .alert("Remove Ingredient", isPresented: Binding(
            get: { showConfirmDeleteIndex != nil },
            set: { if !$0 { showConfirmDeleteIndex = nil } }
        ), presenting: showConfirmDeleteIndex) { idx in
            Button("Remove", role: .destructive) {
                if blacklistStore.items.indices.contains(idx) {
                    blacklistStore.remove(at: idx)
                }
                showConfirmDeleteIndex = nil
            }
            Button("Cancel", role: .cancel) {
                showConfirmDeleteIndex = nil
            }
        } message: { idx in
            Text("Remove \(blacklistStore.items.indices.contains(idx) ? blacklistStore.items[idx] : "this item") from blacklist?")
        }
        .sheet(isPresented: $showCatalogPicker) {
            CatalogPickerView(theme: themeManager, onAdd: { selections in
                for s in selections {
                    blacklistStore.add(s)
                }
                showCatalogPicker = false
            })
        }
    }

    private func addIngredient() {
        let trimmed = newIngredient.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        blacklistStore.add(trimmed)
        newIngredient = ""
    }
}

// Modern catalog picker
struct CatalogPickerView: View {
    @Environment(\.presentationMode) private var presentation
    @ObservedObject var theme: ThemeManager
    @State private var search: String = ""
    @State private var selected: Set<String> = []

    var onAdd: ([String]) -> Void

    private var catalog: [String] = {
        [
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

    init(theme: ThemeManager, onAdd: @escaping ([String]) -> Void) {
        self.theme = theme
        self.onAdd = onAdd
    }

    private var filtered: [String] {
        let term = search.trimmingCharacters(in: .whitespacesAndNewlines)
        if term.isEmpty { return catalog }
        return catalog.filter { $0.localizedCaseInsensitiveContains(term) }
    }

    var body: some View {
        ZStack {
            theme.backgroundColor
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Ingredient Catalog")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(theme.textColor)
                    Text("Add from \(selected.count) selected")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(theme.secondaryTextColor)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                
                // Search
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(theme.secondaryTextColor)
                    TextField("Search", text: $search)
                        .foregroundColor(theme.textColor)
                }
                .padding(12)
                .background(theme.secondaryColor)
                .cornerRadius(12)
                .padding(16)
                
                // List
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
                
                // Actions
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
                .padding(16)
            }
        }
    }
}



