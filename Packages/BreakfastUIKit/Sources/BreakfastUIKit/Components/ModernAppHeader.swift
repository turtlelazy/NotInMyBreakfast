//
//  ModernAppHeader.swift
//  BreakfastUIKit
//
//  Modern app header with theme toggle
//

import SwiftUI

public struct ModernAppHeader: View {
    @ObservedObject var theme: ThemeManager
    let title: String
    let subtitle: String?
    var onThemeToggle: (() -> Void)?
    
    public init(theme: ThemeManager, title: String, subtitle: String? = nil, onThemeToggle: (() -> Void)? = nil) {
        self.theme = theme
        self.title = title
        self.subtitle = subtitle
        self.onThemeToggle = onThemeToggle
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(theme.textColor)
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(theme.secondaryTextColor)
                    }
                }
                
                Spacer()
                
                Button(action: { onThemeToggle?() }) {
                    Image(systemName: theme.isDarkMode ? "sun.max.fill" : "moon.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(theme.accentColor)
                        .padding(10)
                        .background(
                            Circle()
                                .fill(theme.cardBackgroundColor)
                        )
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(theme.cardGradient)
                .shadow(color: Color.black.opacity(0.1), radius: 12, x: 0, y: 4)
        )
        .padding(16)
    }
}

#Preview {
    struct PreviewWrapper: View {
        @StateObject var theme = ThemeManager()
        
        var body: some View {
            VStack {
                ModernAppHeader(
                    theme: theme,
                    title: "Not in My Breakfast",
                    subtitle: "What's in your hot pocket?",
                    onThemeToggle: { theme.isDarkMode.toggle() }
                )
                Spacer()
            }
            .background(theme.backgroundColor)
            .ignoresSafeArea()
        }
    }
    
    return PreviewWrapper()
}
