//
//  GradientButtonModifier.swift
//  NotInMyBreakfast
//
//  Custom ViewModifier for gradient button styling
//

import SwiftUI

public struct GradientButtonModifier: ViewModifier {
    @ObservedObject var theme: ThemeManager
    
    public init(theme: ThemeManager) {
        self.theme = theme
    }
    
    public func body(content: Content) -> some View {
        content
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(theme.primaryGradient)
                    .shadow(color: theme.primaryColor.opacity(0.5), radius: 8, x: 0, y: 4)
            )
    }
}

public extension View {
    func gradientButton(theme: ThemeManager) -> some View {
        modifier(GradientButtonModifier(theme: theme))
    }
}
