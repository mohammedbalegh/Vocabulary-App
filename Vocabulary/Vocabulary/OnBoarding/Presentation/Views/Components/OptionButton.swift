//
//  OptionButton.swift
//  Vocabulary
//
//  Created by Mohammed Balegh on 06/09/2025.
//

import SwiftUI

struct OnBoardingSpacing {
    static let headerHorizontal: CGFloat = 20
    static let headerTop: CGFloat = 40
    static let buttonHorizontal: CGFloat = ScreenSizeConfiguration.isCompactHeight ? 12 : 20
    static let buttonVertical: CGFloat = ScreenSizeConfiguration.isCompactHeight ? 12 : 18
    static let selectionIndicatorSize: CGFloat = 26
}

struct OptionButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    @State private var isPressed = false
    private let hapticProvider: HapticFeedbackProviding
    
    init(
        title: String,
        isSelected: Bool,
        action: @escaping () -> Void,
        hapticProvider: HapticFeedbackProviding = AdvancedHapticManager.shared
    ) {
        self.title = title
        self.isSelected = isSelected
        self.action = action
        self.hapticProvider = hapticProvider
    }
    
    var body: some View {
        Button(action: handleButtonTap) {
            HStack {
                Text(title)
                    .font(AppTypography.button)
                    .foregroundStyle(AppColors.primaryText)
                
                Spacer()
                
                SelectionIndicatorView(isSelected: isSelected)
            }
            .padding(.horizontal, OnBoardingSpacing.buttonHorizontal)
            .padding(.vertical, OnBoardingSpacing.buttonVertical)
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .modifier(SingleOptionButtonBackgroundStyle(isPressed: isPressed))
    }
    
    private func handleButtonTap() {
        animatePress()
        hapticProvider.provideMediumImpact()
        action()
        scheduleRelease()
    }
    
    private func animatePress() {
        withAnimation(AppAnimations.buttonPress) {
            isPressed = true
        }
    }
    
    private func scheduleRelease() {
        DispatchQueue.main.asyncAfter(deadline: .now() + InteractiveButtonConfig.TimingPresets.pressDelay) {
            withAnimation(AppAnimations.buttonRelease) {
                isPressed = false
            }
        }
    }
}

// MARK: - Button Background Style
struct SingleOptionButtonBackgroundStyle: ViewModifier {
    let isPressed: Bool

    func body(content: Content) -> some View {
        content
            .background(backgroundShape)
            .scaleEffect(scaleEffect)
    }
    
    // MARK: - Private Computed Properties
    
    private var backgroundShape: some View {
        RoundedRectangle(cornerRadius: ScreenSizeConfiguration.isCompactHeight ? 12 : 25)
            .stroke(Color.black, lineWidth: 1)
            .fill(isPressed ? AppColors.primaryButton : AppColors.optionButtonColor)
            .overlay(
                RoundedRectangle(cornerRadius: ScreenSizeConfiguration.isCompactHeight ? 12 : 25)
                    .stroke(AppColors.border, lineWidth: 0)
            )
            .shadow(
                color: Color.black,
                radius: 0,
                x: 0,
                y: shadowOffsetY
            )
    }
    
    private var scaleEffect: CGFloat {
        isPressed ? InteractiveButtonConfig.ScalePresets.pressed : InteractiveButtonConfig.ScalePresets.normal
    }
    
    private var shadowColor: Color {
        isPressed ? AppColors.pressedShadow : AppColors.shadow
    }
    
    private var shadowOffsetY: CGFloat {
        isPressed ? 1 : 6
    }
}
