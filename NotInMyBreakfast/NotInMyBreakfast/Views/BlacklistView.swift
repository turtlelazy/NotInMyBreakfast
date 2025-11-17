//
//  BlacklistView.swift
//  NotInMyBreakfast
//
//  Created by Ishraq Mahid on 11/17/25.
//

import Foundation
import SwiftUI
struct BlacklistView: View {
    @State private var blacklist: [String] = ["Gelatin", "Peanuts", "Palm Oil"]
    @State private var newIngredient: String = ""
    
    var body: some View {
        VStack {
            HStack {
                TextField("Add Ingredient", text: $newIngredient)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button("Add") {
                    if !newIngredient.isEmpty {
                        blacklist.append(newIngredient)
                        newIngredient = ""
                    }
                }
            }
            .padding()
            
            List(blacklist, id: \.self) { ingredient in
                Text(ingredient)
            }
        }
        .navigationTitle("Blacklisted Ingredients")
    }
}
