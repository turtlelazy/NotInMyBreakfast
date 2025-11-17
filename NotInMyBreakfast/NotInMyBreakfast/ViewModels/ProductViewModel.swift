//
//  ProductViewModel.swift
//  NotInMyBreakfast
//
//  Created by Ishraq Mahid on 11/17/25.
//

import Foundation

class ProductViewModel: ObservableObject {
    @Published var product: ProductDetails?
    @Published var errorMessage: String?
    
    func fetchProduct(barcode: String) {
        let urlString = "https://world.openfoodfacts.net/api/v2/product/\(barcode).json"
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    return
                }
                
                guard let data = data else { return }
                
                do {
                    let productResponse = try JSONDecoder().decode(Product.self, from: data)
                    self.product = productResponse.product
                } catch {
                    self.errorMessage = "Failed to decode data"
                }
            }
        }.resume()
    }
}
