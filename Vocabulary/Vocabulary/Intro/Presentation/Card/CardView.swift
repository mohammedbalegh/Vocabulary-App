//
//  CardView.swift
//  Vocabulary
//
//  Created by Mohammed Balegh on 05/09/2025.

import SwiftUI

// MARK: - Card Configuration
public struct CardConfiguration {
    public let cornerRadius: CGFloat
    public let horizontalPadding: CGFloat
    public let verticalPadding: CGFloat
    public let subtitleBottomSpacing: CGFloat
    public let statsBottomSpacing: CGFloat
    public let textAnimationDuration: Double
    public let iconAnimationDuration: Double
    public let buttonDelayDuration: Double
    public let backgroundColor: Color
    public let shadowRadius: CGFloat
    public let shadowOffset: CGPoint
    
    public init(
        cornerRadius: CGFloat = 20,
        horizontalPadding: CGFloat = 24,
        verticalPadding: CGFloat = 32,
        subtitleBottomSpacing: CGFloat = 64,
        statsBottomSpacing: CGFloat = 64,
        textAnimationDuration: Double = 0.9,
        iconAnimationDuration: Double = 0.8,
        buttonDelayDuration: Double = 0.4,
        backgroundColor: Color = AppColorPalette.mainBackground,
        shadowRadius: CGFloat = 10,
        shadowOffset: CGPoint = CGPoint(x: 0, y: 5)
    ) {
        self.cornerRadius = cornerRadius
        self.horizontalPadding = horizontalPadding
        self.verticalPadding = verticalPadding
        self.subtitleBottomSpacing = subtitleBottomSpacing
        self.statsBottomSpacing = statsBottomSpacing
        self.textAnimationDuration = textAnimationDuration
        self.iconAnimationDuration = iconAnimationDuration
        self.buttonDelayDuration = buttonDelayDuration
        self.backgroundColor = backgroundColor
        self.shadowRadius = shadowRadius
        self.shadowOffset = shadowOffset
    }
    
    public static let `default` = CardConfiguration()
    public static let compact = CardConfiguration(
        cornerRadius: 16,
        horizontalPadding: 20,
        verticalPadding: 24,
        subtitleBottomSpacing: 48,
        statsBottomSpacing: 48
    )
    public static let spacious = CardConfiguration(
        cornerRadius: 24,
        horizontalPadding: 32,
        verticalPadding: 40,
        subtitleBottomSpacing: 80,
        statsBottomSpacing: 80
    )
}

// MARK: - Card View
public struct CardView: View {
    // MARK: - State Properties
    @State private var isTextVisible = false
    @Binding public var showWalkthrough: Bool
    @State private var isDownloadIconAnimating = false
    @State private var hasAppeared = false
    @State private var animationProgress: Double = 0.0
    
    public let configuration: CardConfiguration
    
    public init(
        showWalkthrough: Binding<Bool>,
        configuration: CardConfiguration = .default
    ) {
        self._showWalkthrough = showWalkthrough
        self.configuration = configuration
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HeaderTextSection(isTextVisible: isTextVisible)
            
            SubtitleSection()
                .padding(.bottom, configuration.subtitleBottomSpacing)
            
            StatsSection()
                .padding(.bottom, configuration.statsBottomSpacing)
            
            HStack {
                Spacer()
                StartButton(hasAppeared: hasAppeared) {
                    handleStartButtonTap()
                }
                Spacer()
            }
        }
        .padding(.horizontal, configuration.horizontalPadding)
        .padding(.vertical, configuration.verticalPadding)
        .background(configuration.backgroundColor)
        .onAppear {
            startAnimationSequence()
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Introduction card")
    }
}

// MARK: - Private Methods
private extension CardView {
    func startAnimationSequence() {
        animateTextVisibility()
        animateDownloadIcon()
        animateAppearanceState()
        startProgressAnimation()
    }
    
    func animateTextVisibility() {
        withAnimation(.easeOut(duration: configuration.textAnimationDuration)) {
            isTextVisible = true
        }
    }
    
    func animateDownloadIcon() {
        withAnimation(
            Animation.easeInOut(duration: configuration.iconAnimationDuration)
                .repeatForever(autoreverses: true)
        ) {
            isDownloadIconAnimating = true
        }
    }
    
    func animateAppearanceState() {
        withAnimation {
            hasAppeared = true
        }
    }
    
    func startProgressAnimation() {
        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
            animationProgress = 1.0
        }
    }
    
    func handleStartButtonTap() {
        // Add haptic feedback
        AdvancedHapticManager.shared.triggerImpactFeedback(style: .medium)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + configuration.buttonDelayDuration) {
            showWalkthrough.toggle()
        }
    }
}

// MARK: - Convenience Extensions
public extension CardView {
    /// Create a compact card view
    static func compact(showWalkthrough: Binding<Bool>) -> CardView {
        CardView(
            showWalkthrough: showWalkthrough,
            configuration: .compact
        )
    }
    
    /// Create a spacious card view
    static func spacious(showWalkthrough: Binding<Bool>) -> CardView {
        CardView(
            showWalkthrough: showWalkthrough,
            configuration: .spacious
        )
    }
}

// MARK: - Preview
#Preview {
    CardView(showWalkthrough: .constant(false))
        .background(Color.gray.opacity(0.1))
}
