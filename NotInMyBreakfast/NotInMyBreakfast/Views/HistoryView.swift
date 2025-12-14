//
//  HistoryView.swift
//  NotInMyBreakfast
//
//  Created by Ishraq Mahid on 11/17/25.
//

import Foundation
import SwiftUI
import BreakfastUIKit

struct HistoryView: View {
    @EnvironmentObject var historyStore: HistoryStore
    @EnvironmentObject var themeManager: ThemeManager
    @State private var showDeleteConfirmation: Bool = false
    
    var body: some View {
        ZStack {
            themeManager.backgroundColor
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Scan History")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(themeManager.textColor)
                    Text("\(historyStore.items.count) scans total")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(themeManager.secondaryTextColor)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                
                if historyStore.items.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 60))
                            .foregroundColor(themeManager.primaryColor)
                        Text("No scan history yet")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(themeManager.textColor)
                        Text("Scanned products will appear here")
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(themeManager.secondaryTextColor)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(historyStore.items) { item in
                                NavigationLink(destination: HistoryDetailView(item: item)
                                    .environmentObject(themeManager)) {
                                    HStack(spacing: 12) {
                                        VStack(alignment: .leading, spacing: 4) {
                                            HStack {
                                                Text(item.productName)
                                                    .font(.system(size: 16, weight: .semibold))
                                                    .foregroundColor(themeManager.textColor)
                                                
                                                Spacer()
                                                
                                                if item.hadBlacklistedIngredients {
                                                    Image(systemName: "exclamationmark.triangle.fill")
                                                        .font(.system(size: 16))
                                                        .foregroundColor(themeManager.warningColor)
                                                } else {
                                                    Image(systemName: "checkmark.circle.fill")
                                                        .font(.system(size: 16))
                                                        .foregroundColor(themeManager.successColor)
                                                }
                                            }
                                            
                                            Text("Barcode: \(item.barcode)")
                                                .font(.system(size: 12, weight: .regular))
                                                .foregroundColor(themeManager.secondaryTextColor)
                                            
                                            Text(formatDate(item.timestamp))
                                                .font(.system(size: 11, weight: .regular))
                                                .foregroundColor(themeManager.secondaryTextColor)
                                                .opacity(0.7)
                                        }
                                    }
                                    .modernCard(theme: themeManager)
                                }
                            }
                        }
                        .padding(16)
                    }
                }
                
                if !historyStore.items.isEmpty {
                    VStack(spacing: 8) {
                        Button(action: { showDeleteConfirmation = true }) {
                            HStack(spacing: 8) {
                                Image(systemName: "trash.circle.fill")
                                Text("Clear All History")
                            }
                            .frame(maxWidth: .infinity)
                            .foregroundColor(themeManager.errorColor)
                            .padding(12)
                            .background(themeManager.errorColor.opacity(0.1))
                            .cornerRadius(12)
                        }
                    }
                    .padding(16)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .alert("Clear History", isPresented: $showDeleteConfirmation) {
            Button("Clear All", role: .destructive) {
                historyStore.removeAll()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to clear all scan history? This cannot be undone.")
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
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        ZStack {
            themeManager.backgroundColor
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(item.productName)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(themeManager.textColor)
                        
                        HStack {
                            Image(systemName: "barcode")
                                .foregroundColor(themeManager.primaryColor)
                            Text(item.barcode)
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(themeManager.secondaryTextColor)
                        }
                        
                        HStack {
                            Image(systemName: "calendar")
                                .foregroundColor(themeManager.primaryColor)
                            Text(formatDate(item.timestamp))
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(themeManager.secondaryTextColor)
                        }
                    }
                    .modernCard(theme: themeManager)
                    
                    // Status card
                    HStack(spacing: 12) {
                        if item.hadBlacklistedIngredients {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 20))
                                .foregroundColor(themeManager.warningColor)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Contains Blacklisted Items")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(themeManager.textColor)
                                Text("This product has restricted ingredients")
                                    .font(.system(size: 12, weight: .regular))
                                    .foregroundColor(themeManager.secondaryTextColor)
                            }
                        } else {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 20))
                                .foregroundColor(themeManager.successColor)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Safe to Consume")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(themeManager.textColor)
                                Text("No blacklisted ingredients detected")
                                    .font(.system(size: 12, weight: .regular))
                                    .foregroundColor(themeManager.secondaryTextColor)
                            }
                        }
                        Spacer()
                    }
                    .modernCard(theme: themeManager)
                    
                    if item.hadBlacklistedIngredients && !item.blacklistedIngredients.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "list.bullet")
                                    .foregroundColor(themeManager.warningColor)
                                Text("Blacklisted Ingredients")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(themeManager.textColor)
                            }
                            
                            VStack(spacing: 8) {
                                ForEach(item.blacklistedIngredients, id: \.self) { ingredient in
                                    HStack {
                                        Circle()
                                            .fill(themeManager.warningColor)
                                            .frame(width: 6, height: 6)
                                        Text(ingredient)
                                            .font(.system(size: 14, weight: .regular))
                                            .foregroundColor(themeManager.textColor)
                                        Spacer()
                                    }
                                    .padding(8)
                                    .background(themeManager.cardBackgroundColor)
                                    .cornerRadius(8)
                                }
                            }
                        }
                        .padding(16)
                        .background(themeManager.warningColor.opacity(0.05))
                        .cornerRadius(16)
                    }
                    
                    Spacer()
                }
                .padding(16)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateStyle = .long
        formatter.timeStyle = .medium
        return formatter.string(from: date)
    }
}
