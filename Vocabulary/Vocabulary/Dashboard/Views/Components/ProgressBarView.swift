//
//  ProgressBarConfiguration.swift
//  Vocabulary
//
//  Created by Mohammed Balegh on 08/09/2025.
//

import SwiftUI

// MARK: - Progress Bar Configuration
public struct ProgressBarConfiguration {
    public let iconSize: CGFloat
    public let textSize: CGFloat
    public let barHeight: CGFloat
    public let cornerRadius: CGFloat
    public let spacing: CGFloat
    public let animationResponse: Double
    public let animationDamping: Double
    public let glowRadius: CGFloat
    public let pulseScale: CGFloat
    public let accessibilityLabel: String
    
    public init(
        iconSize: CGFloat = 16,
        textSize: CGFloat = 14,
        barHeight: CGFloat = 4,
        cornerRadius: CGFloat = 2,
        spacing: CGFloat = 12,
        animationResponse: Double = 0.4,
        animationDamping: Double = 0.8,
        glowRadius: CGFloat = 8,
        pulseScale: CGFloat = 1.05,
        accessibilityLabel: String = "Learning Progress"
    ) {
        self.iconSize = iconSize
        self.textSize = textSize
        self.barHeight = barHeight
        self.cornerRadius = cornerRadius
        self.spacing = spacing
        self.animationResponse = animationResponse
        self.animationDamping = animationDamping
        self.glowRadius = glowRadius
        self.pulseScale = pulseScale
        self.accessibilityLabel = accessibilityLabel
    }
    
    public static let `default` = ProgressBarConfiguration()
    public static let compact = ProgressBarConfiguration(
        iconSize: 14,
        textSize: 12,
        barHeight: 3,
        spacing: 8
    )
    public static let prominent = ProgressBarConfiguration(
        iconSize: 18,
        textSize: 16,
        barHeight: 6,
        cornerRadius: 3,
        spacing: 16,
        glowRadius: 12
    )
}

// MARK: - Progress Animation Style
public enum ProgressAnimationStyle {
    case smooth
    case bouncy
    case linear
    case pulse
}

// MARK: - Progress Bar View
public struct ProgressView: View {
    public let progress: Double
    public let text: String
    public let configuration: ProgressBarConfiguration
    public let animationStyle: ProgressAnimationStyle
    public let showGlow: Bool
    public let showPulse: Bool
    
    @State private var animatedProgress: Double = 0
    @State private var isAnimating: Bool = false
    @State private var pulseScale: CGFloat = 1.0
    @State private var glowIntensity: Double = 0.0
    
    public init(
        progress: Double,
        text: String,
        configuration: ProgressBarConfiguration = .default,
        animationStyle: ProgressAnimationStyle = .smooth,
        showGlow: Bool = true,
        showPulse: Bool = true
    ) {
        self.progress = progress
        self.text = text
        self.configuration = configuration
        self.animationStyle = animationStyle
        self.showGlow = showGlow
        self.showPulse = showPulse
    }
    
    public var body: some View {
        HStack(spacing: configuration.spacing) {
            bookmarkIcon
            progressText
            progressBar
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(configuration.accessibilityLabel): \(text)")
        .accessibilityValue("\(Int(progress * 100)) percent complete")
        .onChange(of: progress) { _, newProgress in
            animateProgress(to: newProgress)
        }
        .onAppear {
            animatedProgress = progress
            startPulseAnimation()
        }
    }
    
    // MARK: - Icon Component
    private var bookmarkIcon: some View {
        Image(systemName: "bookmark.fill")
            .foregroundColor(.white)
            .font(.system(size: configuration.iconSize, weight: .medium))
            .scaleEffect(pulseScale)
            .animation(
                showPulse ? .easeInOut(duration: 1.5).repeatForever(autoreverses: true) : .default,
                value: pulseScale
            )
    }
    
    // MARK: - Text Component
    private var progressText: some View {
        Text(text)
            .foregroundColor(.white)
            .font(.system(size: configuration.textSize, weight: .medium))
            .lineLimit(1)
            .minimumScaleFactor(0.8)
    }
    
    // MARK: - Progress Bar Component
    private var progressBar: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                backgroundBar
                foregroundBar(geometry: geometry)
                if showGlow {
                    glowEffect(geometry: geometry)
                }
            }
        }
        .frame(height: configuration.barHeight)
    }
    
    // MARK: - Background Bar
    private var backgroundBar: some View {
        RoundedRectangle(cornerRadius: configuration.cornerRadius)
            .fill(Color.white.opacity(0.3))
            .frame(height: configuration.barHeight)
    }
    
    // MARK: - Foreground Bar
    private func foregroundBar(geometry: GeometryProxy) -> some View {
        RoundedRectangle(cornerRadius: configuration.cornerRadius)
            .fill(
                LinearGradient(
                    colors: [.white, .white.opacity(0.9)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(
                width: geometry.size.width * animatedProgress,
                height: configuration.barHeight
            )
            .overlay(
                RoundedRectangle(cornerRadius: configuration.cornerRadius)
                    .stroke(Color.white.opacity(0.5), lineWidth: 0.5)
            )
    }
    
    // MARK: - Glow Effect
    private func glowEffect(geometry: GeometryProxy) -> some View {
        RoundedRectangle(cornerRadius: configuration.cornerRadius)
            .fill(Color.white)
            .frame(
                width: geometry.size.width * animatedProgress,
                height: configuration.barHeight
            )
            .blur(radius: configuration.glowRadius * glowIntensity)
            .opacity(glowIntensity * 0.6)
    }
    
    // MARK: - Animation Logic
    private func animateProgress(to newProgress: Double) {
        isAnimating = true
        
        // Animate glow effect
        if showGlow {
            withAnimation(.easeInOut(duration: 0.3)) {
                glowIntensity = 1.0
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    glowIntensity = 0.0
                }
            }
        }
        
        // Animate progress based on style
        let animation = animationForStyle(animationStyle)
        
        withAnimation(animation) {
            animatedProgress = newProgress
        }
        
        // Reset animation state
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            isAnimating = false
        }
    }
    
    private func animationForStyle(_ style: ProgressAnimationStyle) -> Animation {
        switch style {
        case .smooth:
            return .spring(
                response: configuration.animationResponse,
                dampingFraction: configuration.animationDamping
            )
        case .bouncy:
            return .spring(
                response: 0.6,
                dampingFraction: 0.5
            )
        case .linear:
            return .easeInOut(duration: 0.5)
        case .pulse:
            return .spring(
                response: 0.3,
                dampingFraction: 0.6
            )
        }
    }
    
    private func startPulseAnimation() {
        guard showPulse else { return }
        
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            pulseScale = configuration.pulseScale
        }
    }
}

// MARK: - Convenience Extensions
public extension ProgressView {
    /// Create a compact progress bar
    static func compact(
        progress: Double,
        text: String,
        animationStyle: ProgressAnimationStyle = .smooth
    ) -> ProgressView {
        ProgressView(
            progress: progress,
            text: text,
            configuration: .compact,
            animationStyle: animationStyle
        )
    }
    
    /// Create a prominent progress bar
    static func prominent(
        progress: Double,
        text: String,
        animationStyle: ProgressAnimationStyle = .smooth
    ) -> ProgressView {
        ProgressView(
            progress: progress,
            text: text,
            configuration: .prominent,
            animationStyle: animationStyle
        )
    }
    
    /// Create a progress bar with bouncy animation
    static func bouncy(
        progress: Double,
        text: String,
        configuration: ProgressBarConfiguration = .default
    ) -> ProgressView {
        ProgressView(
            progress: progress,
            text: text,
            configuration: configuration,
            animationStyle: .bouncy
        )
    }
}
