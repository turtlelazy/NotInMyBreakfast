//
//  HistoryView.swift
//  NotInMyBreakfast
//
//  Created by Ishraq Mahid on 11/17/25.
//

import Foundation
import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var historyStore: HistoryStore
    @State private var showDeleteConfirmation: Bool = false
    
    var body: some View {
        Group {
            if historyStore.items.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.system(size: 60))
                        .foregroundColor(.secondary)
                    Text("No scan history yet")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Text("Scanned products will appear here")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(historyStore.items) { item in
                        NavigationLink(destination: HistoryDetailView(item: item)) {
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Text(item.productName)
                                        .font(.headline)
                                    Spacer()
                                    if item.hadBlacklistedIngredients {
                                        Image(systemName: "exclamationmark.triangle.fill")
                                            .foregroundColor(.orange)
                                    } else {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.green)
                                    }
                                }
                                
                                Text("Barcode: \(item.barcode)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Text(formatDate(item.timestamp))
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .onDelete(perform: deleteItems)
                }
            }
        }
        .navigationTitle("Scan History")
        .toolbar {
            if !historyStore.items.isEmpty {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showDeleteConfirmation = true }) {
                        Image(systemName: "trash")
                    }
                }
            }
        }
        .alert("Clear History", isPresented: $showDeleteConfirmation) {
            Button("Clear All", role: .destructive) {
                historyStore.removeAll()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to clear all scan history?")
        }
    }
    
    private func deleteItems(at offsets: IndexSet) {
        for index in offsets {
            historyStore.remove(at: index)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// Detail view for individual history items
struct HistoryDetailView: View {
    let item: HistoryItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(item.productName)
                .font(.title2)
                .bold()
            
            HStack {
                Text("Barcode:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(item.barcode)
                    .font(.subheadline)
            }
            
            HStack {
                Text("Scanned:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(formatDate(item.timestamp))
                    .font(.subheadline)
            }
            
            Divider()
            
            HStack {
                if item.hadBlacklistedIngredients {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                    Text("Contained blacklisted ingredients")
                        .font(.subheadline)
                } else {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("No blacklisted ingredients found")
                        .font(.subheadline)
                }
            }
            .padding()
            .background(item.hadBlacklistedIngredients ? Color.orange.opacity(0.1) : Color.green.opacity(0.1))
            .cornerRadius(8)
            
            if item.hadBlacklistedIngredients && !item.blacklistedIngredients.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Blacklisted Ingredients:")
                        .font(.headline)
                        .padding(.top, 8)
                    
                    ForEach(item.blacklistedIngredients, id: \.self) { ingredient in
                        HStack {
                            Image(systemName: "circle.fill")
                                .font(.system(size: 6))
                                .foregroundColor(.orange)
                            Text(ingredient)
                                .font(.subheadline)
                        }
                        .padding(.leading, 8)
                    }
                }
                .padding(.top, 8)
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("Scan Details")
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateStyle = .long
        formatter.timeStyle = .medium
        return formatter.string(from: date)
    }
}
