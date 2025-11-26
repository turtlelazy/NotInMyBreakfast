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



