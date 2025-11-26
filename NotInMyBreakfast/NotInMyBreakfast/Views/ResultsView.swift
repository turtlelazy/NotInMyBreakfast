//
//  ResultsView.swift
//  NotInMyBreakfast
//
//  Created by Ishraq Mahid on 11/17/25.
//

import Foundation
import SwiftUI

struct ResultsView: View {
    private let details: ProductDetails
    @State private var blacklist: [String] = ["Gelatin", "Peanuts", "Palm Oil"]

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
            
            let matchedIngredients = details.ingredients?.filter { ingredient in
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
