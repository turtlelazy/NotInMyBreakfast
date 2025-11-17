//
//  Product.swift
//  NotInMyBreakfast
//
//  Created by Ishraq Mahid on 11/17/25.
//

import Foundation

struct Product: Codable {
    let code: String
    let product: ProductDetails?
}

struct ProductDetails: Codable {
    let productName: String?
    let ingredientsText: String?
    let ingredients: [Ingredient]?
}
