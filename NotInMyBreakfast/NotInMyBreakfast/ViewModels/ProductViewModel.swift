//
//  ProductViewModel.swift
//  NotInMyBreakfast
//
//  Created by Ishraq Mahid on 11/17/25.
//

import Foundation

// MARK: - API Error Type

enum APIError: LocalizedError {
    case barcodeNotFound(barcode: String)
    case productDataUnavailable(barcode: String)
    case networkError(Error)
    case invalidResponse
    case decodingError(Error)
    case serverError(statusCode: Int)
    case noData
    
    var errorDescription: String? {
        switch self {
        case .barcodeNotFound(let barcode):
            return "Barcode not found: No product with barcode '\(barcode)' in database"
        case .productDataUnavailable(let barcode):
            return "Product not found: Barcode '\(barcode)' exists but has no data available"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid response from server"
        case .decodingError(let error):
            return "Failed to process data: \(error.localizedDescription)"
        case .serverError(let statusCode):
            return "Server error: HTTP \(statusCode)"
        case .noData:
            return "No data received from server"
        }
    }
}

// MARK: - Product View Model

class ProductViewModel: ObservableObject {
    @Published var product: ProductDetails?
    @Published var errorMessage: String?
    
    func fetchProduct(barcode: String) {
        let urlString = "https://world.openfoodfacts.net/api/v2/product/\(barcode).json"
        guard let url = URL(string: urlString) else { 
            handleError(.invalidResponse)
            return
        }
        print("ProductViewModel: fetching product for barcode=\(barcode) url=\(urlString)")

        URLSession.shared.dataTask(with: url) { data, response, error in
            // Check for network errors first
            if let error = error {
                self.handleError(.networkError(error))
                return
            }

            // Check HTTP response status code
            if let httpResponse = response as? HTTPURLResponse {
                print("ProductViewModel: HTTP status code: \(httpResponse.statusCode)")
                
                if httpResponse.statusCode == 404 {
                    self.handleError(.barcodeNotFound(barcode: barcode))
                    return
                } else if httpResponse.statusCode >= 400 {
                    self.handleError(.serverError(statusCode: httpResponse.statusCode))
                    return
                }
            }

            guard let data = data else {
                self.handleError(.noData)
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
                    // Check if product details are available
                    if let product = productResponse.product {
                        self.product = product
                        self.errorMessage = nil
                        print("ProductViewModel: decoded product: \(String(describing: product))")
                    } else {
                        // API returned success but no product details
                        self.handleError(.productDataUnavailable(barcode: barcode))
                    }
                }
            } catch {
                self.handleError(.decodingError(error))
            }
        }.resume()
    }
    
    private func handleError(_ error: APIError) {
        DispatchQueue.main.async {
            self.product = nil
            self.errorMessage = error.errorDescription
            print("ProductViewModel: \(error.errorDescription ?? "Unknown error")")
        }
    }
}
