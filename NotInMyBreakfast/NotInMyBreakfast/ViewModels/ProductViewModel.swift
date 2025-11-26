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
        print("ProductViewModel: fetching product for barcode=\(barcode) url=\(urlString)")

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                    print("ProductViewModel: network error: \(error)")
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    self.errorMessage = "No data received"
                    print("ProductViewModel: no data received from \(urlString)")
                }
                return
            }

            // Print raw JSON response for debugging
            if let jsonString = String(data: data, encoding: .utf8) {
                print("ProductViewModel: raw response JSON:\n\(jsonString)")
            }

            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let productResponse = try decoder.decode(Product.self, from: data)
                DispatchQueue.main.async {
                    self.product = productResponse.product
                    print("ProductViewModel: decoded product: \(String(describing: productResponse.product))")
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to decode data: \(error.localizedDescription)"
                    print("ProductViewModel: decode error: \(error)\nData (utf8): \(String(data: data, encoding: .utf8) ?? "<non-utf8>")")
                }
            }
        }.resume()
    }
}
