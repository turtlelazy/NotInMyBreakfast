//
//  ModernProgressView.swift
//  NotInMyBreakfast
//
//  Modern animated progress indicator using UIViewRepresentable
//

import SwiftUI
import UIKit

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
