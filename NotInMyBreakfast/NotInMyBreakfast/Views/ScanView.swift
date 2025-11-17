//
//  ScanView.swift
//  NotInMyBreakfast
//
//  Created by Ishraq Mahid on 11/17/25.
//

import Foundation
import SwiftUI
import AVFoundation

struct ScanView: View {
    @State private var scannedCode: String = ""
    @ObservedObject var viewModel = ProductViewModel()
    
    var body: some View {
        VStack {
            Text("Scanned Code: \(scannedCode)")
                .padding()
            
            Button("Simulate Scan") {
                // Replace with real scanner
                scannedCode = "737628064502"
                viewModel.fetchProduct(barcode: scannedCode)
            }
            
            if let product = viewModel.product {
                NavigationLink("View Results", destination: ResultsView(product: product))
            }
            
            if let error = viewModel.errorMessage {
                Text("Error: \(error)").foregroundColor(.red)
            }
        }
        .navigationTitle("Scan")
    }
}
