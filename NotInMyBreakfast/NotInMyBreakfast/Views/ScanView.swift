//
//  ScanView.swift
//  NotInMyBreakfast
//
//  Created by Ishraq Mahid on 11/17/25.
//

import Foundation
import SwiftUI
import AVFoundation
import UIKit

struct ScanView: View {
    @State private var scannedCode: String = ""
    @State private var isScanning: Bool = false
    @ObservedObject var viewModel = ProductViewModel()
    @EnvironmentObject var historyStore: HistoryStore
    @EnvironmentObject var blacklistStore: BlacklistStore
    enum InputMode { case manual, camera, image }
    @State private var mode: InputMode = .camera
    @State private var showImagePicker: Bool = false
    @State private var pickedImage: UIImage?
    @State private var manualCode: String = ""

    var body: some View {
        VStack(spacing: 16) {
            ZStack(alignment: .topTrailing) {
                // Input mode UI: manual / camera preview / image preview
                switch mode {
                case .camera:
                    if isScanning {
                        BarcodeScannerView(scannedCode: $scannedCode, isScanning: $isScanning)
                            .frame(height: 360)
                            .cornerRadius(12)
                            .shadow(radius: 4)
                    } else {
                        Rectangle()
                            .fill(Color.secondary.opacity(0.2))
                            .frame(height: 360)
                            .cornerRadius(12)
                            .overlay(Text("Camera preview"))
                    }

                    Button(action: { isScanning.toggle() }) {
                        Text(isScanning ? "Stop" : "Start")
                            .padding(8)
                            .background(Color.black.opacity(0.6))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                            .padding()
                    }

                case .image:
                    if let img = pickedImage {
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 360)
                            .cornerRadius(12)
                            .shadow(radius: 4)
                    } else {
                        Rectangle()
                            .fill(Color.secondary.opacity(0.12))
                            .frame(height: 360)
                            .cornerRadius(12)
                            .overlay(Text("No image selected"))
                    }

                    Button(action: { showImagePicker = true }) {
                        Text("Pick from Gallery")
                            .padding(8)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                            .padding()
                    }

                case .manual:
                    Rectangle()
                        .fill(Color.secondary.opacity(0.06))
                        .frame(height: 120)
                        .cornerRadius(12)
                        .overlay(
                            VStack {
                                TextField("Enter barcode", text: $manualCode)
                                    .keyboardType(.numberPad)
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(8)
                                    .padding(.horizontal)

                                Button(action: {
                                    let code = manualCode.trimmingCharacters(in: .whitespacesAndNewlines)
                                    guard !code.isEmpty else { return }
                                    scannedCode = code
                                    viewModel.fetchProduct(barcode: code)
                                }) {
                                    Text("Fetch")
                                        .padding(8)
                                        .background(Color.green)
                                        .foregroundColor(.white)
                                        .cornerRadius(8)
                                }
                            }
                            .padding()
                        )
                }
            }

            // Mode selection buttons
            HStack(spacing: 12) {
                Button(action: {
                    mode = .manual
                    isScanning = false
                }) {
                    Text("Manual")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(mode == .manual ? Color.accentColor : Color.gray.opacity(0.2))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }

                Button(action: {
                    mode = .camera
                    pickedImage = nil
                    // start camera automatically
                    isScanning = true
                }) {
                    Text("Camera")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(mode == .camera ? Color.accentColor : Color.gray.opacity(0.2))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }

                Button(action: {
                    mode = .image
                    isScanning = false
                    showImagePicker = true
                }) {
                    Text("Image")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(mode == .image ? Color.accentColor : Color.gray.opacity(0.2))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .padding(.horizontal)

            Text("Scanned Code: \(scannedCode)")
                .font(.subheadline)
                .padding(.horizontal)

            if let product = viewModel.product {
                NavigationLink("View Results", destination: ResultsView(product: product, image: pickedImage))
                    .padding()
                    .onAppear {
                        // Save to history when product is successfully fetched
                        saveToHistory(product: product)
                    }
            }

            if let error = viewModel.errorMessage {
                Text("Error: \(error)").foregroundColor(.red).padding()
            }

            Spacer()
        }
        .padding()
        .navigationTitle("Scan")
        .onChange(of: scannedCode) { newCode in
            guard !newCode.isEmpty else { return }
            viewModel.fetchProduct(barcode: newCode)
        }
        .onChange(of: pickedImage) { image in
            guard let image = image else { return }
            // Run barcode detection on the picked image
            BarcodeDetector.detectBarcode(from: image) { payload in
                DispatchQueue.main.async {
                    if let code = payload {
                        scannedCode = code
                        viewModel.fetchProduct(barcode: code)
                    }
                }
            }
        }
        .onAppear {
            // Reset any previous state
            scannedCode = ""
            isScanning = false
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(selectedImage: $pickedImage)
        }
    }
    
    // Helper function to save scan to history
    private func saveToHistory(product: ProductDetails) {
        let productName = product.productName ?? "Unknown Product"
        
        // Check if product has blacklisted ingredients
        let matchedIngredients = product.ingredients?.filter { ingredient in
            guard let text = ingredient.text else { return false }
            return blacklistStore.items.contains { text.localizedCaseInsensitiveContains($0) }
        } ?? []
        
        let hadBlacklistedIngredients = !matchedIngredients.isEmpty
        
        // Save to history
        historyStore.addScan(
            barcode: scannedCode,
            productName: productName,
            hadBlacklistedIngredients: hadBlacklistedIngredients
        )
    }
}
