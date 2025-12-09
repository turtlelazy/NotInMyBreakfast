//
//  UIComponents.swift
//  NotInMyBreakfast
//
//  Central file containing all UI components, theme management, and deep linking
//

import SwiftUI
import UIKit

// MARK: - Theme Manager

public class ThemeManager: ObservableObject {
    @AppStorage("app_theme") public var isDarkMode: Bool = false {
        didSet {
            objectWillChange.send()
        }
    }
    
    public init() {}
    
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

// MARK: - ViewModifiers

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
    func modernCard(theme: ThemeManager) -> some View {
        modifier(ModernCardModifier(theme: theme))
    }
    
    func gradientButton(theme: ThemeManager) -> some View {
        modifier(GradientButtonModifier(theme: theme))
    }
}

// MARK: - UI Components

public struct ModernProgressView: UIViewRepresentable {
    @Binding var progress: Double
    var lineWidth: CGFloat = 8
    var colors: [UIColor] = [UIColor(red: 0, green: 0.7, blue: 0.9, alpha: 1)]
    
    public init(progress: Binding<Double>, lineWidth: CGFloat = 8, colors: [UIColor]? = nil) {
        self._progress = progress
        self.lineWidth = lineWidth
        if let colors = colors {
            self.colors = colors
        }
    }
    
    public func makeUIView(context: Context) -> ProgressCircleView {
        let view = ProgressCircleView()
        view.lineWidth = lineWidth
        view.colors = colors
        return view
    }
    
    public func updateUIView(_ uiView: ProgressCircleView, context: Context) {
        uiView.setProgress(CGFloat(progress), animated: true)
    }
}

public class ProgressCircleView: UIView {
    private let shapeLayer = CAShapeLayer()
    private let trackLayer = CAShapeLayer()
    private let animationDuration: TimeInterval = 0.3
    
    public var lineWidth: CGFloat = 8 {
        didSet { updateLayers() }
    }
    
    public var colors: [UIColor] = [UIColor(red: 0, green: 0.7, blue: 0.9, alpha: 1)] {
        didSet { updateLayers() }
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setupLayers()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayers()
    }
    
    private func setupLayers() {
        backgroundColor = .clear
        layer.addSublayer(trackLayer)
        layer.addSublayer(shapeLayer)
    }
    
    private func updateLayers() {
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius = min(bounds.width, bounds.height) / 2 - lineWidth / 2
        let path = UIBezierPath(arcCenter: center, radius: radius, startAngle: -CGFloat.pi / 2, endAngle: 3 * CGFloat.pi / 2, clockwise: true)
        
        trackLayer.path = path.cgPath
        trackLayer.strokeColor = UIColor.gray.withAlphaComponent(0.2).cgColor
        trackLayer.lineWidth = lineWidth
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.lineCap = .round
        
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = colors.first?.cgColor ?? UIColor.systemBlue.cgColor
        shapeLayer.lineWidth = lineWidth
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineCap = .round
        shapeLayer.lineJoin = .round
        shapeLayer.strokeEnd = 0
    }
    
    public func setProgress(_ progress: CGFloat, animated: Bool = true) {
        let clampedProgress = max(0, min(progress, 1))
        
        if animated {
            let animation = CABasicAnimation(keyPath: "strokeEnd")
            animation.toValue = clampedProgress
            animation.duration = animationDuration
            animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            animation.fillMode = .forwards
            animation.isRemovedOnCompletion = false
            shapeLayer.add(animation, forKey: "progress")
        } else {
            shapeLayer.strokeEnd = clampedProgress
        }
    }
    
    override public var intrinsicContentSize: CGSize {
        return CGSize(width: 100, height: 100)
    }
}

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
