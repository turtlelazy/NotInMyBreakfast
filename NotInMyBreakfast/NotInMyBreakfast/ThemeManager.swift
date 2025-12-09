//
//  ThemeManager.swift
//  NotInMyBreakfast
//
//  Manages light and dark theme colors and styles
//

import SwiftUI

public class ThemeManager: ObservableObject {
    @AppStorage("app_theme") public var isDarkMode: Bool = false {
        didSet {
            objectWillChange.send()
        }
    }
    
    public init() {}
    
    // MARK: - Colors
    
    public var primaryColor: Color {
        isDarkMode ? Color(red: 0.2, green: 0.8, blue: 0.9) : Color(red: 0.0, green: 0.7, blue: 0.9)
    }
    
    public var secondaryColor: Color {
        isDarkMode ? Color(red: 0.15, green: 0.15, blue: 0.3) : Color(red: 0.95, green: 0.95, blue: 1.0)
    }
    
    public var backgroundColor: Color {
        isDarkMode ? Color(red: 0.08, green: 0.08, blue: 0.12) : Color.white
    }
    
    public var cardBackgroundColor: Color {
        isDarkMode ? Color(red: 0.12, green: 0.12, blue: 0.18) : Color(red: 0.97, green: 0.97, blue: 0.99)
    }
    
    public var textColor: Color {
        isDarkMode ? Color.white : Color.black
    }
    
    public var secondaryTextColor: Color {
        isDarkMode ? Color(red: 0.7, green: 0.7, blue: 0.8) : Color(red: 0.3, green: 0.3, blue: 0.3)
    }
    
    public var accentColor: Color {
        isDarkMode ? Color(red: 1.0, green: 0.6, blue: 0.2) : Color(red: 1.0, green: 0.5, blue: 0.0)
    }
    
    public var successColor: Color {
        Color(red: 0.2, green: 0.8, blue: 0.4)
    }
    
    public var warningColor: Color {
        Color(red: 1.0, green: 0.6, blue: 0.2)
    }
    
    public var errorColor: Color {
        Color(red: 1.0, green: 0.3, blue: 0.3)
    }
    
    // MARK: - Gradients
    
    public var primaryGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [primaryColor, primaryColor.opacity(0.7)]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    public var cardGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [
                cardBackgroundColor,
                cardBackgroundColor.opacity(0.8)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
