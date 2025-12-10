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
    @StateObject private var viewModel = ProductViewModel()
    @EnvironmentObject var historyStore: HistoryStore
    @EnvironmentObject var blacklistStore: BlacklistStore
    @EnvironmentObject var themeManager: ThemeManager
    @State private var initialBarcode: String?
    @State private var isShowingResults: Bool = false
    @State private var showResults: Bool = false
    enum InputMode { case manual, camera, image }
    @State private var mode: InputMode = .camera
    @State private var showImagePicker: Bool = false
    @State private var pickedImage: UIImage?
    @State private var manualCode: String = ""
    @State private var lastSavedBarcode: String = ""
    @State private var loadingProgress: Double = 0

    init(initialBarcode: String? = nil) {
        self._initialBarcode = State(initialValue: initialBarcode)
    }

    var body: some View {
        ZStack {
            themeManager.backgroundColor
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                // Modern header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Scan Product")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(themeManager.textColor)
                    Text("Choose a scanning method")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(themeManager.secondaryTextColor)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                
                ScrollView {
                    VStack(spacing: 16) {
                        // Mode selection buttons with modern design
                        HStack(spacing: 12) {
                            ModeButton(title: "Manual", icon: "keyboard", isSelected: mode == .manual, theme: themeManager) {
                                mode = .manual
                                isScanning = false
                            }
                            
                            ModeButton(title: "Camera", icon: "camera.fill", isSelected: mode == .camera, theme: themeManager) {
                                mode = .camera
                                pickedImage = nil
                                isScanning = true
                            }
                            
                            ModeButton(title: "Image", icon: "photo.fill", isSelected: mode == .image, theme: themeManager) {
                                mode = .image
                                isScanning = false
                                showImagePicker = true
                            }
                        }
                        .padding(16)
                        
                        // Input mode UI
                        switch mode {
                        case .camera:
                            cameraSection()
                        case .image:
                            imageSection()
                        case .manual:
                            manualSection()
                        }
                        
                        // Loading progress
                        if !scannedCode.isEmpty && viewModel.product == nil && viewModel.errorMessage == nil {
                            VStack(spacing: 12) {
                                ModernProgressView(progress: $loadingProgress)
                                    .frame(height: 80)
                                Text("Fetching product details...")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(themeManager.secondaryTextColor)
                            }
                            .modernCard(theme: themeManager)
                            .padding(16)
                        }
                        
                        // Results
                        if let product = viewModel.product {
                            NavigationLink(isActive: $showResults, destination: {
                                ResultsView(product: product, image: pickedImage)
                                    .environmentObject(blacklistStore)
                                    .environmentObject(themeManager)
                            }, label: {
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(themeManager.successColor)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Product Found")
                                            .font(.system(size: 14, weight: .semibold))
                                        Text(product.productName ?? "Unknown")
                                            .font(.system(size: 12, weight: .regular))
                                            .lineLimit(1)
                                    }
                                    
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(themeManager.secondaryTextColor)
                                }
                                .foregroundColor(themeManager.textColor)
                                .modernCard(theme: themeManager)
                            })
                            .padding(16)
                        }
                        
                        // Error message with retry option
                        if let error = viewModel.errorMessage {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack(spacing: 12) {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .font(.system(size: 16))
                                        .foregroundColor(themeManager.errorColor)
                                    Text("Error")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(themeManager.errorColor)
                                }
                                Text(error)
                                    .font(.system(size: 12, weight: .regular))
                                    .foregroundColor(themeManager.secondaryTextColor)
                                
                                // Retry button for barcode not found
                                if error.contains("not found") {
                                    Button(action: {
                                        viewModel.errorMessage = nil
                                        viewModel.product = nil
                                        scannedCode = ""
                                        if mode == .camera {
                                            isScanning = true
                                        }
                                    }) {
                                        HStack(spacing: 8) {
                                            Image(systemName: "arrow.clockwise")
                                            Text("Try Again")
                                        }
                                        .frame(maxWidth: .infinity)
                                        .foregroundColor(themeManager.primaryColor)
                                        .padding(12)
                                        .background(themeManager.primaryColor.opacity(0.1))
                                        .cornerRadius(12)
                                    }
                                    .padding(.top, 8)
                                }
                            }
                            .modernCard(theme: themeManager)
                            .padding(16)
                        }
                    }
                }
                
                Spacer()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: scannedCode) { newCode in
            guard !newCode.isEmpty else { return }
            loadingProgress = 0.2
            viewModel.errorMessage = nil  // Clear previous errors
            viewModel.product = nil        // Clear previous product
            viewModel.fetchProduct(barcode: newCode)
        }
        .onChange(of: viewModel.product) { product in
            loadingProgress = 1.0
            if let product = product, scannedCode != lastSavedBarcode, !scannedCode.isEmpty {
                lastSavedBarcode = scannedCode
                saveToHistory(product: product)
            }
            // Stop scanning and automatically navigate when product is loaded
            if product != nil {
                isScanning = false
                isShowingResults = true
                // Delay slightly to ensure UI is ready, then trigger navigation
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    showResults = true
                }
            }
        }
        .onChange(of: showResults) { isShowing in
            // When user navigates back from results (showResults becomes false)
            if !isShowing && isShowingResults {
                isShowingResults = false
                viewModel.product = nil
                scannedCode = ""
                lastSavedBarcode = ""
                // Resume scanning if in camera mode
                if mode == .camera {
                    isScanning = true
                }
            }
        }
        .onChange(of: pickedImage) { image in
            guard let image = image else { return }
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
            if let initialBarcode = initialBarcode {
                scannedCode = initialBarcode
                viewModel.fetchProduct(barcode: initialBarcode)
            } else if mode == .camera && !isShowingResults {
                isScanning = true
            }
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(selectedImage: $pickedImage)
        }
    }
    
    @ViewBuilder
    private func cameraSection() -> some View {
        VStack(spacing: 12) {
            if isScanning {
                BarcodeScannerView(scannedCode: $scannedCode, isScanning: $isScanning)
                    .frame(height: 300)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.1), radius: 12, x: 0, y: 4)
            } else {
                Rectangle()
                    .fill(themeManager.cardBackgroundColor)
                    .frame(height: 300)
                    .cornerRadius(16)
                    .overlay(
                        VStack(spacing: 12) {
                            Image(systemName: "camera.viewfinder")
                                .font(.system(size: 48))
                                .foregroundColor(themeManager.primaryColor)
                            Text("Camera Ready")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(themeManager.textColor)
                            #if targetEnvironment(simulator)
                            Text("⚠️ Not available in simulator")
                                .font(.caption)
                                .foregroundColor(themeManager.warningColor)
                            #endif
                        }
                    )
                    .shadow(color: Color.black.opacity(0.1), radius: 12, x: 0, y: 4)
            }
            
            Button(action: {
                isScanning.toggle()
            }) {
                HStack(spacing: 8) {
                    Image(systemName: isScanning ? "stop.fill" : "play.fill")
                    Text(isScanning ? "Stop Scanning" : "Start Scanning")
                }
            }
            .gradientButton(theme: themeManager)
        }
        .padding(16)
    }
    
    @ViewBuilder
    private func imageSection() -> some View {
        VStack(spacing: 12) {
            if let img = pickedImage {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 300)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.1), radius: 12, x: 0, y: 4)
            } else {
                Rectangle()
                    .fill(themeManager.cardBackgroundColor)
                    .frame(height: 300)
                    .cornerRadius(16)
                    .overlay(
                        VStack(spacing: 12) {
                            Image(systemName: "photo.fill")
                                .font(.system(size: 48))
                                .foregroundColor(themeManager.primaryColor)
                            Text("No Image Selected")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(themeManager.textColor)
                        }
                    )
                    .shadow(color: Color.black.opacity(0.1), radius: 12, x: 0, y: 4)
            }
            
            Button(action: { showImagePicker = true }) {
                HStack(spacing: 8) {
                    Image(systemName: "photo.on.rectangle")
                    Text("Pick from Gallery")
                }
            }
            .gradientButton(theme: themeManager)
        }
        .padding(16)
    }
    
    @ViewBuilder
    private func manualSection() -> some View {
        VStack(spacing: 12) {
            VStack(spacing: 12) {
                TextField("Enter barcode", text: $manualCode)
                    .keyboardType(.numberPad)
                    .padding(12)
                    .background(themeManager.secondaryColor)
                    .cornerRadius(12)
                    .foregroundColor(themeManager.textColor)
                
                Button(action: {
                    let code = manualCode.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !code.isEmpty else { return }
                    scannedCode = code
                    viewModel.fetchProduct(barcode: code)
                    manualCode = ""
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                        Text("Fetch Product")
                    }
                }
                .gradientButton(theme: themeManager)
            }
            .modernCard(theme: themeManager)
        }
        .padding(16)
    }
    
    private func saveToHistory(product: ProductDetails) {
        let productName = product.productName ?? "Unknown Product"
        let matchedIngredients = product.ingredients?.filter { ingredient in
            guard let text = ingredient.text else { return false }
            return blacklistStore.items.contains { text.localizedCaseInsensitiveContains($0) }
        } ?? []
        
        let hadBlacklistedIngredients = !matchedIngredients.isEmpty
        let blacklistedList = matchedIngredients.compactMap { $0.text }
        
        historyStore.addScan(
            barcode: scannedCode,
            productName: productName,
            hadBlacklistedIngredients: hadBlacklistedIngredients,
            blacklistedIngredients: blacklistedList
        )
    }
}

// Modern mode button component
struct ModeButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    @ObservedObject var theme: ThemeManager
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                Text(title)
                    .font(.system(size: 12, weight: .semibold))
            }
            .frame(maxWidth: .infinity)
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color(red: 0.0, green: 0.7, blue: 0.9) : theme.cardBackgroundColor)
            )
            .foregroundColor(isSelected ? .white : theme.textColor)
        }
    }
}
