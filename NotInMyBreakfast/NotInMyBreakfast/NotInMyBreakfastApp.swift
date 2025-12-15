//
//  NotInMyBreakfastApp.swift
//  NotInMyBreakfast
//
//  Created by Ishraq Mahid on 11/16/25.
//

import SwiftUI
import BreakfastUIKit

@main
struct NotInMyBreakfastApp: App {
    @StateObject private var blacklistStore = BlacklistStore()
    @StateObject private var historyStore = HistoryStore()
    @StateObject private var themeManager = ThemeManager()
    @State private var navigationPath = NavigationPath()
    @State private var deepLink: DeepLink? = nil
    @State private var hasHandledColdStart = false

    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $navigationPath) {
                ZStack {
                    themeManager.backgroundColor
                        .ignoresSafeArea()
                    
                    VStack(spacing: 0) {
                        ModernAppHeader(
                            theme: themeManager,
                            title: "Not in My Breakfast",
                            subtitle: "What's in your hot pocket?",
                            onThemeToggle: { themeManager.isDarkMode.toggle() }
                        )
                        
                        Spacer()
                        
                        homeContent()
                        
                        Spacer()
                    }
                }
                .navigationDestination(for: DeepLink.self) { link in
                    deepLinkView(for: link)
                }
            }
            .environmentObject(blacklistStore)
            .environmentObject(historyStore)
            .environmentObject(themeManager)
            .onOpenURL { url in
                handleDeepLink(url: url)
            }
            .onAppear {
                // Handle cold-start deep linking
                if !hasHandledColdStart {
                    hasHandledColdStart = true
                    if let link = deepLink, link != .home && link != .invalid {
                        navigationPath.append(link)
                    }
                }
            }
            .onChange(of: deepLink) { newValue in
                // Handle deep link changes after app is running
                if hasHandledColdStart, let link = newValue, link != .home && link != .invalid {
                    navigationPath.append(link)
                }
            }
            .preferredColorScheme(themeManager.isDarkMode ? .dark : .light)
        }
    }
    
    private func handleDeepLink(url: URL) {
        let link = DeepLink(url: url)
        deepLink = link
    }
    
    @ViewBuilder
    private func homeContent() -> some View {
        VStack(spacing: 16) {
            NavigationLink(destination: ScanView()
                .environmentObject(blacklistStore)
                .environmentObject(historyStore)
                .environmentObject(themeManager)) {
                HStack(spacing: 12) {
                    Image(systemName: "barcode.viewfinder")
                        .font(.system(size: 24, weight: .semibold))
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Scan Barcode")
                            .font(.system(size: 18, weight: .semibold))
                        Text("Check product ingredients")
                            .font(.system(size: 12, weight: .regular))
                            .opacity(0.7)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .semibold))
                        .opacity(0.5)
                }
                .foregroundColor(themeManager.textColor)
                .modernCard(theme: themeManager)
            }
            
            NavigationLink(destination: BlacklistView()
                .environmentObject(blacklistStore)
                .environmentObject(themeManager)) {
                HStack(spacing: 12) {
                    Image(systemName: "checkmark.shield")
                        .font(.system(size: 24, weight: .semibold))
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Blacklisted Ingredients")
                            .font(.system(size: 18, weight: .semibold))
                        Text("Manage your preferences")
                            .font(.system(size: 12, weight: .regular))
                            .opacity(0.7)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .semibold))
                        .opacity(0.5)
                }
                .foregroundColor(themeManager.textColor)
                .modernCard(theme: themeManager)
            }
            
            NavigationLink(destination: HistoryView()
                .environmentObject(historyStore)
                .environmentObject(themeManager)) {
                HStack(spacing: 12) {
                    Image(systemName: "clock.fill")
                        .font(.system(size: 24, weight: .semibold))
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Results History")
                            .font(.system(size: 18, weight: .semibold))
                        Text("View past scans")
                            .font(.system(size: 12, weight: .regular))
                            .opacity(0.7)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .semibold))
                        .opacity(0.5)
                }
                .foregroundColor(themeManager.textColor)
                .modernCard(theme: themeManager)
            }
        }
        .padding(16)
    }
    
    @ViewBuilder
    private func deepLinkView(for link: DeepLink) -> some View {
        switch link {
        case .home:
            homeContent()
        case .scanProduct(let barcode):
            ScanView(initialBarcode: barcode)
                .environmentObject(blacklistStore)
                .environmentObject(historyStore)
                .environmentObject(themeManager)
        case .viewBlacklist:
            BlacklistView()
                .environmentObject(blacklistStore)
                .environmentObject(themeManager)
        case .viewHistory:
            HistoryView()
                .environmentObject(historyStore)
                .environmentObject(themeManager)
        case .invalid:
            Text("Invalid deep link")
        }
    }
}
