//
//  StartButton.swift
//  Vocabulary
//
//  Created by Mohammed Balegh on 05/09/2025.
//

import SwiftUI

// MARK: - Start Button Configuration
public struct StartButtonConfiguration {
    public let buttonText: String
    public let fontSize: CGFloat
    public let fontWeight: Font.Weight
    public let textColor: Color
    public let backgroundColor: Color
    public let cornerRadius: CGFloat
    public let shadowRadius: CGFloat
    public let shadowOffset: CGPoint
    public let shadowColor: Color
    public let horizontalPadding: CGFloat
    public let verticalPadding: CGFloat
    public let animationDelay: Double
    public let pressScale: CGFloat
    public let pressOpacity: Double
    public let pressAnimationDuration: Double
    
    public init(
        buttonText: String = "Jump In",
        fontSize: CGFloat = 16,
        fontWeight: Font.Weight = .bold,
        textColor: Color = .black,
        backgroundColor: Color = AppColorPalette.actionButton,
        cornerRadius: CGFloat = 28,
        shadowRadius: CGFloat = 1,
        shadowOffset: CGPoint = CGPoint(x: 0, y: 6),
        shadowColor: Color = .black,
        horizontalPadding: CGFloat = 20,
        verticalPadding: CGFloat = 0,
        animationDelay: Double = 0.6,
        pressScale: CGFloat = 0.97,
        pressOpacity: Double = 0.8,
        pressAnimationDuration: Double = 0.2
    ) {
        self.buttonText = buttonText
        self.fontSize = fontSize
        self.fontWeight = fontWeight
        self.textColor = textColor
        self.backgroundColor = backgroundColor
        self.cornerRadius = cornerRadius
        self.shadowRadius = shadowRadius
        self.shadowOffset = shadowOffset
        self.shadowColor = shadowColor
        self.horizontalPadding = horizontalPadding
        self.verticalPadding = verticalPadding
        self.animationDelay = animationDelay
        self.pressScale = pressScale
        self.pressOpacity = pressOpacity
        self.pressAnimationDuration = pressAnimationDuration
    }
    
    public static let `default` = StartButtonConfiguration()
    public static let compact = StartButtonConfiguration(
        fontSize: 14,
        cornerRadius: 20,
        horizontalPadding: 16
    )
    public static let prominent = StartButtonConfiguration(
        fontSize: 18,
        cornerRadius: 32,
        horizontalPadding: 24
    )
}

// MARK: - Start Button
public struct StartButton: View {
    public let hasAppeared: Bool
    public let onTap: () -> Void
    public let configuration: StartButtonConfiguration
    
    @State private var isPressed = false
    
    public init(
        hasAppeared: Bool,
        onTap: @escaping () -> Void,
        configuration: StartButtonConfiguration = .default
    ) {
        self.hasAppeared = hasAppeared
        self.onTap = onTap
        self.configuration = configuration
    }
    
    public var body: some View {
        Button(action: handleTap) {
            Text(configuration.buttonText)
        }
        .buttonStyle(AnimatedButtonStyle(configuration: configuration))
        .opacity(hasAppeared ? 1 : 0)
        .offset(y: hasAppeared ? 0 : 50)
        .padding(.horizontal, configuration.horizontalPadding)
        .padding(.vertical, configuration.verticalPadding)
        .animation(AnimationLibrary.defaultEaseOut.delay(configuration.animationDelay), value: hasAppeared)
        .accessibilityLabel("Start learning")
        .accessibilityHint("Tap to begin the vocabulary learning journey")
    }
    
    private func handleTap() {
        // Add haptic feedback
        AdvancedHapticManager.shared.triggerImpactFeedback(style: .medium)
        onTap()
    }
}

// MARK: - Animated Button Style
private struct AnimatedButtonStyle: ButtonStyle {
    let configuration: StartButtonConfiguration
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: self.configuration.fontSize, weight: self.configuration.fontWeight))
            .foregroundColor(self.configuration.textColor)
            .frame(
                width: nil,
                height: DeviceLayoutManager.isCompactHeight ? 45 : 56
            )
            .frame(maxWidth: .infinity)
            .background(self.configuration.backgroundColor)
            .cornerRadius(self.configuration.cornerRadius)
            .shadow(
                color: self.configuration.shadowColor,
                radius: self.configuration.shadowRadius,
                x: self.configuration.shadowOffset.x,
                y: self.configuration.shadowOffset.y
            )
            .opacity(configuration.isPressed ? self.configuration.pressOpacity : 1)
            .scaleEffect(configuration.isPressed ? self.configuration.pressScale : 1.0)
            .animation(.easeInOut(duration: self.configuration.pressAnimationDuration), value: configuration.isPressed)
    }
}

// MARK: - Convenience Extensions
public extension StartButton {
    /// Create a compact start button
    static func compact(
        hasAppeared: Bool,
        onTap: @escaping () -> Void
    ) -> StartButton {
        StartButton(
            hasAppeared: hasAppeared,
            onTap: onTap,
            configuration: .compact
        )
    }
    
    /// Create a prominent start button
    static func prominent(
        hasAppeared: Bool,
        onTap: @escaping () -> Void
    ) -> StartButton {
        StartButton(
            hasAppeared: hasAppeared,
            onTap: onTap,
            configuration: .prominent
        )
    }
}
