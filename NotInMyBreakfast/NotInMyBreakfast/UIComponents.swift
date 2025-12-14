//
//  UIComponents.swift
//  NotInMyBreakfast
//
//  Central file containing all UI components, theme management, and deep linking
//

import SwiftUI
import BreakfastUIKit

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
