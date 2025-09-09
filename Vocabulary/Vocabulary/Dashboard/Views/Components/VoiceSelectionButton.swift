//
//  VoiceSelectionButton.swift
//  Vocabulary
//
//  Created by Mohammed Balegh on 08/09/2025.
//

import SwiftUI
import AVFoundation

// MARK: - Voice Selection Configuration
public struct VoiceSelectionConfiguration {
    public let compactButtonSize: CGFloat
    public let compactButtonPadding: CGFloat
    public let compactButtonCornerRadius: CGFloat
    public let expandedMenuPadding: CGFloat
    public let expandedMenuCornerRadius: CGFloat
    public let voiceButtonWidth: CGFloat
    public let voiceButtonPadding: CGFloat
    public let voiceButtonCornerRadius: CGFloat
    public let flagFontSize: CGFloat
    public let chevronFontSize: CGFloat
    public let voiceNameFontSize: CGFloat
    public let checkmarkFontSize: CGFloat
    public let animationResponse: Double
    public let animationDamping: Double
    public let shadowRadius: CGFloat
    public let shadowOpacity: Double
    
    public init(
        compactButtonSize: CGFloat = 20,
        compactButtonPadding: CGFloat = 8,
        compactButtonCornerRadius: CGFloat = 20,
        expandedMenuPadding: CGFloat = 8,
        expandedMenuCornerRadius: CGFloat = 16,
        voiceButtonWidth: CGFloat = 160,
        voiceButtonPadding: CGFloat = 12,
        voiceButtonCornerRadius: CGFloat = 12,
        flagFontSize: CGFloat = 16,
        chevronFontSize: CGFloat = 12,
        voiceNameFontSize: CGFloat = 14,
        checkmarkFontSize: CGFloat = 12,
        animationResponse: Double = 0.3,
        animationDamping: Double = 0.8,
        shadowRadius: CGFloat = 8,
        shadowOpacity: Double = 0.2
    ) {
        self.compactButtonSize = compactButtonSize
        self.compactButtonPadding = compactButtonPadding
        self.compactButtonCornerRadius = compactButtonCornerRadius
        self.expandedMenuPadding = expandedMenuPadding
        self.expandedMenuCornerRadius = expandedMenuCornerRadius
        self.voiceButtonWidth = voiceButtonWidth
        self.voiceButtonPadding = voiceButtonPadding
        self.voiceButtonCornerRadius = voiceButtonCornerRadius
        self.flagFontSize = flagFontSize
        self.chevronFontSize = chevronFontSize
        self.voiceNameFontSize = voiceNameFontSize
        self.checkmarkFontSize = checkmarkFontSize
        self.animationResponse = animationResponse
        self.animationDamping = animationDamping
        self.shadowRadius = shadowRadius
        self.shadowOpacity = shadowOpacity
    }
    
    public static let `default` = VoiceSelectionConfiguration()
    public static let compact = VoiceSelectionConfiguration(
        compactButtonSize: 16,
        compactButtonPadding: 6,
        compactButtonCornerRadius: 16,
        voiceButtonWidth: 140,
        voiceButtonPadding: 10,
        flagFontSize: 14,
        chevronFontSize: 10,
        voiceNameFontSize: 12,
        checkmarkFontSize: 10
    )
    public static let prominent = VoiceSelectionConfiguration(
        compactButtonSize: 24,
        compactButtonPadding: 12,
        compactButtonCornerRadius: 24,
        voiceButtonWidth: 180,
        voiceButtonPadding: 16,
        flagFontSize: 18,
        chevronFontSize: 14,
        voiceNameFontSize: 16,
        checkmarkFontSize: 14
    )
}

// MARK: - Voice Selection Style
public enum VoiceSelectionStyle {
    case standard
    case minimal
    case prominent
}

// MARK: - Voice Selection Button
public struct VoiceSelectionButton: View {
    public let currentVoice: SpeechAccent
    public let onVoiceChange: (SpeechAccent) -> Void
    public let configuration: VoiceSelectionConfiguration
    public let style: VoiceSelectionStyle
    public let showHapticFeedback: Bool
    
    @State private var isExpanded = false
    @State private var isPressed = false
    @State private var selectedVoice: SpeechAccent
    @State private var animationPhase: Double = 0.0
    
    public init(
        currentVoice: SpeechAccent,
        onVoiceChange: @escaping (SpeechAccent) -> Void,
        configuration: VoiceSelectionConfiguration = .default,
        style: VoiceSelectionStyle = .standard,
        showHapticFeedback: Bool = true
    ) {
        self.currentVoice = currentVoice
        self.onVoiceChange = onVoiceChange
        self.configuration = configuration
        self.style = style
        self.showHapticFeedback = showHapticFeedback
        self._selectedVoice = State(initialValue: currentVoice)
    }
    
    public var body: some View {
        ZStack {
            if isExpanded {
                expandedMenu
            } else {
                compactButton
            }
        }
        .animation(
            .spring(
                response: configuration.animationResponse,
                dampingFraction: configuration.animationDamping
            ),
            value: isExpanded
        )
        .onChange(of: currentVoice) { _, newVoice in
            selectedVoice = newVoice
        }
        .onAppear {
            startIdleAnimation()
        }
    }
    
    // MARK: - Compact Button
    private var compactButton: some View {
        Button(action: toggleExpansion) {
            HStack(spacing: 6) {
                Text(selectedVoice.countryFlag)
                    .font(.system(size: configuration.flagFontSize))
                    .scaleEffect(1.0 + animationPhase * 0.1)
                
                Image(systemName: "chevron.down")
                    .font(.system(size: configuration.chevronFontSize, weight: .medium))
                    .rotationEffect(.degrees(isExpanded ? 180 : 0))
                    .scaleEffect(isPressed ? 0.9 : 1.0)
            }
            .padding(.horizontal, configuration.compactButtonPadding + 4)
            .padding(.vertical, configuration.compactButtonPadding)
            .background(compactButtonBackground)
            .overlay(compactButtonBorder)
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .foregroundColor(.white)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
        .accessibilityLabel("Voice selection: \(selectedVoice.localizedName)")
        .accessibilityHint("Tap to change pronunciation accent")
    }
    
    // MARK: - Compact Button Background
    private var compactButtonBackground: some View {
        RoundedRectangle(cornerRadius: configuration.compactButtonCornerRadius)
            .fill(AppColorPalette.cardBackground.opacity(0.8))
            .overlay(
                RoundedRectangle(cornerRadius: configuration.compactButtonCornerRadius)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.1),
                                Color.clear
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            )
    }
    
    // MARK: - Compact Button Border
    private var compactButtonBorder: some View {
        RoundedRectangle(cornerRadius: configuration.compactButtonCornerRadius)
            .stroke(AppColorPalette.borderSubtle, lineWidth: 1)
    }
    
    // MARK: - Expanded Menu
    private var expandedMenu: some View {
        VStack(spacing: 8) {
            ForEach(SpeechAccent.allCases) { voice in
                VoiceButton(
                    voice: voice,
                    isSelected: voice == selectedVoice,
                    configuration: configuration,
                    onTap: {
                        selectVoice(voice)
                    }
                )
            }
        }
        .padding(configuration.expandedMenuPadding)
        .background(menuBackground)
        .overlay(menuBorder)
    }
    
    // MARK: - Voice Button
    private struct VoiceButton: View {
        let voice: SpeechAccent
        let isSelected: Bool
        let configuration: VoiceSelectionConfiguration
        let onTap: () -> Void
        
        @State private var isPressed = false
        
        var body: some View {
            Button(action: onTap) {
                HStack(spacing: 8) {
                    Text(voice.countryFlag)
                        .font(.system(size: configuration.flagFontSize))
                    
                    Text(voice.localizedName)
                        .font(.system(size: configuration.voiceNameFontSize, weight: .medium))
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                    
                    Spacer()
                    
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: configuration.checkmarkFontSize, weight: .bold))
                            .foregroundColor(AppColorPalette.highlightAccent)
                    }
                }
                .foregroundColor(isSelected ? AppColorPalette.highlightAccent : .white)
                .padding(.horizontal, configuration.voiceButtonPadding + 4)
                .padding(.vertical, configuration.voiceButtonPadding)
                .frame(width: configuration.voiceButtonWidth)
                .background(voiceButtonBackground)
                .overlay(voiceButtonBorder)
                .scaleEffect(isPressed ? 0.95 : 1.0)
            }
            .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
                isPressed = pressing
            }, perform: {})
            .accessibilityLabel("\(voice.localizedName) accent")
            .accessibilityHint(isSelected ? "Currently selected" : "Tap to select")
        }
        
        private var voiceButtonBackground: some View {
            RoundedRectangle(cornerRadius: configuration.voiceButtonCornerRadius)
                .fill(
                    isSelected ?
                    AppColorPalette.highlightAccent.opacity(0.2) :
                    AppColorPalette.cardBackground.opacity(0.9)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: configuration.voiceButtonCornerRadius)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(isSelected ? 0.2 : 0.1),
                                    Color.clear
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                )
        }
        
        private var voiceButtonBorder: some View {
            RoundedRectangle(cornerRadius: configuration.voiceButtonCornerRadius)
                .stroke(
                    isSelected ? AppColorPalette.highlightAccent : AppColorPalette.borderSubtle,
                    lineWidth: isSelected ? 2 : 1
                )
        }
    }
    
    // MARK: - Menu Background
    private var menuBackground: some View {
        RoundedRectangle(cornerRadius: configuration.expandedMenuCornerRadius)
            .fill(AppColorPalette.cardBackground.opacity(0.95))
            .overlay(
                RoundedRectangle(cornerRadius: configuration.expandedMenuCornerRadius)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.1),
                                Color.clear
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            )
    }
    
    // MARK: - Menu Border
    private var menuBorder: some View {
        RoundedRectangle(cornerRadius: configuration.expandedMenuCornerRadius)
            .stroke(AppColorPalette.borderSubtle, lineWidth: 1)
    }
    
    // MARK: - Actions
    private func toggleExpansion() {
        if showHapticFeedback {
            AdvancedHapticManager.shared.triggerSelectionFeedback()
        }
        
        withAnimation {
            isExpanded.toggle()
        }
    }
    
    private func selectVoice(_ voice: SpeechAccent) {
        if showHapticFeedback {
            AdvancedHapticManager.shared.triggerImpactFeedback(style: .medium)
        }
        
        selectedVoice = voice
        onVoiceChange(voice)
        
        withAnimation {
            isExpanded = false
        }
    }
    
    private func startIdleAnimation() {
        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
            animationPhase = 1.0
        }
    }
}

// MARK: - Convenience Extensions
public extension VoiceSelectionButton {
    /// Create a compact voice selection button
    static func compact(
        currentVoice: SpeechAccent,
        onVoiceChange: @escaping (SpeechAccent) -> Void,
        showHapticFeedback: Bool = true
    ) -> VoiceSelectionButton {
        VoiceSelectionButton(
            currentVoice: currentVoice,
            onVoiceChange: onVoiceChange,
            configuration: .compact,
            showHapticFeedback: showHapticFeedback
        )
    }
    
    /// Create a prominent voice selection button
    static func prominent(
        currentVoice: SpeechAccent,
        onVoiceChange: @escaping (SpeechAccent) -> Void,
        showHapticFeedback: Bool = true
    ) -> VoiceSelectionButton {
        VoiceSelectionButton(
            currentVoice: currentVoice,
            onVoiceChange: onVoiceChange,
            configuration: .prominent,
            showHapticFeedback: showHapticFeedback
        )
    }
    
    /// Create a minimal voice selection button
    static func minimal(
        currentVoice: SpeechAccent,
        onVoiceChange: @escaping (SpeechAccent) -> Void,
        showHapticFeedback: Bool = true
    ) -> VoiceSelectionButton {
        VoiceSelectionButton(
            currentVoice: currentVoice,
            onVoiceChange: onVoiceChange,
            configuration: .compact,
            style: .minimal,
            showHapticFeedback: showHapticFeedback
        )
    }
}
