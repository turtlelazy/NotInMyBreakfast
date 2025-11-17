//
//  ResultsView.swift
//  NotInMyBreakfast
//
//  Created by Ishraq Mahid on 11/17/25.
//

import Foundation
import SwiftUI

struct ResultsView: View {
    let product: ProductDetails
    @State private var blacklist: [String] = ["Gelatin", "Peanuts", "Palm Oil"]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Product: \(product.productName ?? "Unknown")")
                .font(.headline)
            
            Text("Ingredients: \(product.ingredientsText ?? "N/A")")
            
            let matchedIngredients = product.ingredients?.filter { ingredient in
                guard let text = ingredient.text else { return false }
                return blacklist.contains { text.localizedCaseInsensitiveContains($0) }
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
        }
        .padding()
        .navigationTitle("Results")
    }
}
