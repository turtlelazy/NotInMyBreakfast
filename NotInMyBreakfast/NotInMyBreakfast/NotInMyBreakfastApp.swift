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
    @State private var deepLink: DeepLink? = nil

    var body: some Scene {
        WindowGroup {
            NavigationView {
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
                            .navigationDestination(for: DeepLink.self) { link in
                                deepLinkView(for: link)
                            }
                        
                        Spacer()
                    }
                }
            }
            .environmentObject(blacklistStore)
            .environmentObject(historyStore)
            .environmentObject(themeManager)
            .onOpenURL { url in
                deepLink = DeepLink(url: url)
            }
            .preferredColorScheme(themeManager.isDarkMode ? .dark : .light)
        }
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

// MARK: - Deep Linking

public enum DeepLink: Hashable {
    case home
    case scanProduct(barcode: String)
    case viewBlacklist
    case viewHistory
    case invalid
    
    public init(url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            self = .invalid
            return
        }
        
        self = DeepLink.parse(components: components)
    }
    
    private static func parse(components: URLComponents) -> DeepLink {
        guard let host = components.host else {
            return .home
        }
        
        switch host.lowercased() {
        case "home":
            return .home
            
        case "scan":
            if let barcode = components.queryItems?.first(where: { $0.name == "barcode" })?.value,
               !barcode.isEmpty {
                return .scanProduct(barcode: barcode)
            }
            return .invalid
            
        case "blacklist":
            return .viewBlacklist
            
        case "history":
            return .viewHistory
            
        default:
            return .invalid
        }
    }
    
    public func toURLString() -> String {
        switch self {
        case .home:
            return "notinmybreakfast://home"
        case .scanProduct(let barcode):
            return "notinmybreakfast://scan?barcode=\(barcode)"
        case .viewBlacklist:
            return "notinmybreakfast://blacklist"
        case .viewHistory:
            return "notinmybreakfast://history"
        case .invalid:
            return ""
        }
    }
}
