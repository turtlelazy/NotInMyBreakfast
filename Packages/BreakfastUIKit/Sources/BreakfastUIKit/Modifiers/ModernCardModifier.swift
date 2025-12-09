//
//  ModernCardModifier.swift
//  BreakfastUIKit
//
//  Custom ViewModifier for modern card design with glass morphism effect
//

import SwiftUI

public struct ModernCardModifier: ViewModifier {
    @ObservedObject var theme: ThemeManager
    
    public init(theme: ThemeManager) {
        self.theme = theme
    }
    
    public func body(content: Content) -> some View {
        content
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(theme.cardGradient)
                    .shadow(color: Color.black.opacity(0.1), radius: 12, x: 0, y: 4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(theme.isDarkMode ? 0.1 : 0.2),
                                Color.white.opacity(theme.isDarkMode ? 0.05 : 0.1)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
    }
}

public extension View {
    func modernCard(theme: ThemeManager) -> some View {
        modifier(ModernCardModifier(theme: theme))
    }
}
