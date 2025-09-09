//
//  OnboardingFlowViewConfiguration.swift
//  Vocabulary
//
//  Created by Mohammed Balegh on 06/09/2025.
//

import SwiftUI

// MARK: - Main Configuration
public struct OnboardingFlowViewConfiguration {
    // MARK: - Background
    public let backgroundColor: Color
    public let backgroundOverlay: AnyView?
    public let backgroundOverlayOpacity: Double
    
    // MARK: - Layout
    public let maxContentWidth: CGFloat
    public let horizontalPadding: CGFloat
    public let verticalPadding: CGFloat
    
    // MARK: - Progress Indicator
    public let showProgressIndicator: Bool
    public let progressIndicatorSpacing: CGFloat
    public let progressIndicatorBottomPadding: CGFloat
    public let progressTextFont: Font
    public let progressTextColor: Color
    public let progressBarColor: Color
    public let progressBarHeight: CGFloat
    
    // MARK: - Navigation Controls
    public let showNavigationControls: Bool
    public let navigationControlsSpacing: CGFloat
    public let navigationControlsTopPadding: CGFloat
    
    // MARK: - Back Button
    public let backButtonFont: Font
    public let backButtonColor: Color
    public let backButtonBackgroundColor: Color
    public let backButtonCornerRadius: CGFloat
    public let backButtonHorizontalPadding: CGFloat
    public let backButtonVerticalPadding: CGFloat
    
    // MARK: - Skip Button
    public let skipButtonFont: Font
    public let skipButtonColor: Color
    public let skipButtonBackgroundColor: Color
    public let skipButtonCornerRadius: CGFloat
    public let skipButtonHorizontalPadding: CGFloat
    public let skipButtonVerticalPadding: CGFloat
    
    // MARK: - Animations
    public let stepTransitionAnimation: Animation
    public let entranceAnimation: Animation
    
    // MARK: - Step Configurations
    public let singleSelectionConfiguration: SingleSelectionStepConfiguration
    public let multiSelectionConfiguration: MultiSelectionStepConfiguration
    public let nameInputConfiguration: NameInputStepConfiguration
    public let tailorStepConfiguration: TailorStepConfiguration
    
    public init(
        backgroundColor: Color = AppColorPalette.background,
        backgroundOverlay: AnyView? = nil,
        backgroundOverlayOpacity: Double = 0.0,
        maxContentWidth: CGFloat = 400,
        horizontalPadding: CGFloat = 20,
        verticalPadding: CGFloat = 20,
        showProgressIndicator: Bool = true,
        progressIndicatorSpacing: CGFloat = 8,
        progressIndicatorBottomPadding: CGFloat = 20,
        progressTextFont: Font = TypographySystem.body,
        progressTextColor: Color = AppColorPalette.textSecondary,
        progressBarColor: Color = AppColorPalette.accent,
        progressBarHeight: CGFloat = 2,
        showNavigationControls: Bool = true,
        navigationControlsSpacing: CGFloat = 16,
        navigationControlsTopPadding: CGFloat = 20,
        backButtonFont: Font = TypographySystem.button,
        backButtonColor: Color = AppColorPalette.textPrimary,
        backButtonBackgroundColor: Color = AppColorPalette.surface,
        backButtonCornerRadius: CGFloat = 8,
        backButtonHorizontalPadding: CGFloat = 16,
        backButtonVerticalPadding: CGFloat = 12,
        skipButtonFont: Font = TypographySystem.button,
        skipButtonColor: Color = AppColorPalette.textSecondary,
        skipButtonBackgroundColor: Color = Color.clear,
        skipButtonCornerRadius: CGFloat = 8,
        skipButtonHorizontalPadding: CGFloat = 16,
        skipButtonVerticalPadding: CGFloat = 12,
        stepTransitionAnimation: Animation = AnimationLibrary.easeInOut,
        entranceAnimation: Animation = AnimationLibrary.spring,
        singleSelectionConfiguration: SingleSelectionStepConfiguration = .default,
        multiSelectionConfiguration: MultiSelectionStepConfiguration = .default,
        nameInputConfiguration: NameInputStepConfiguration = .default,
        tailorStepConfiguration: TailorStepConfiguration = .default
    ) {
        self.backgroundColor = backgroundColor
        self.backgroundOverlay = backgroundOverlay
        self.backgroundOverlayOpacity = backgroundOverlayOpacity
        self.maxContentWidth = maxContentWidth
        self.horizontalPadding = horizontalPadding
        self.verticalPadding = verticalPadding
        self.showProgressIndicator = showProgressIndicator
        self.progressIndicatorSpacing = progressIndicatorSpacing
        self.progressIndicatorBottomPadding = progressIndicatorBottomPadding
        self.progressTextFont = progressTextFont
        self.progressTextColor = progressTextColor
        self.progressBarColor = progressBarColor
        self.progressBarHeight = progressBarHeight
        self.showNavigationControls = showNavigationControls
        self.navigationControlsSpacing = navigationControlsSpacing
        self.navigationControlsTopPadding = navigationControlsTopPadding
        self.backButtonFont = backButtonFont
        self.backButtonColor = backButtonColor
        self.backButtonBackgroundColor = backButtonBackgroundColor
        self.backButtonCornerRadius = backButtonCornerRadius
        self.backButtonHorizontalPadding = backButtonHorizontalPadding
        self.backButtonVerticalPadding = backButtonVerticalPadding
        self.skipButtonFont = skipButtonFont
        self.skipButtonColor = skipButtonColor
        self.skipButtonBackgroundColor = skipButtonBackgroundColor
        self.skipButtonCornerRadius = skipButtonCornerRadius
        self.skipButtonHorizontalPadding = skipButtonHorizontalPadding
        self.skipButtonVerticalPadding = skipButtonVerticalPadding
        self.stepTransitionAnimation = stepTransitionAnimation
        self.entranceAnimation = entranceAnimation
        self.singleSelectionConfiguration = singleSelectionConfiguration
        self.multiSelectionConfiguration = multiSelectionConfiguration
        self.nameInputConfiguration = nameInputConfiguration
        self.tailorStepConfiguration = tailorStepConfiguration
    }
    
    public static let `default` = OnboardingFlowViewConfiguration(
        showProgressIndicator: false
    )
}

// MARK: - Step Configuration Types
public struct SingleSelectionStepConfiguration {
    public let titleFont: Font
    public let subtitleFont: Font
    public let optionButtonStyle: any ButtonStyle
    public let spacing: CGFloat
    
    public init(
        titleFont: Font = TypographySystem.headline,
        subtitleFont: Font = TypographySystem.body,
        optionButtonStyle: any ButtonStyle = PlainButtonStyle(),
        spacing: CGFloat = 16
    ) {
        self.titleFont = titleFont
        self.subtitleFont = subtitleFont
        self.optionButtonStyle = optionButtonStyle
        self.spacing = spacing
    }
    
    public static let `default` = SingleSelectionStepConfiguration()
}

public struct MultiSelectionStepConfiguration {
    public let titleFont: Font
    public let subtitleFont: Font
    public let optionButtonStyle: any ButtonStyle
    public let spacing: CGFloat
    public let maxSelections: Int
    
    public init(
        titleFont: Font = TypographySystem.headline,
        subtitleFont: Font = TypographySystem.body,
        optionButtonStyle: any ButtonStyle = PlainButtonStyle(),
        spacing: CGFloat = 16,
        maxSelections: Int = 5
    ) {
        self.titleFont = titleFont
        self.subtitleFont = subtitleFont
        self.optionButtonStyle = optionButtonStyle
        self.spacing = spacing
        self.maxSelections = maxSelections
    }
    
    public static let `default` = MultiSelectionStepConfiguration()
}

public struct NameInputStepConfiguration {
    public let titleFont: Font
    public let subtitleFont: Font
    public let textFieldStyle: any TextFieldStyle
    public let spacing: CGFloat
    
    public init(
        titleFont: Font = TypographySystem.headline,
        subtitleFont: Font = TypographySystem.body,
        textFieldStyle: any TextFieldStyle = .plain,
        spacing: CGFloat = 16
    ) {
        self.titleFont = titleFont
        self.subtitleFont = subtitleFont
        self.textFieldStyle = textFieldStyle
        self.spacing = spacing
    }
    
    public static let `default` = NameInputStepConfiguration()
}

public struct TailorStepConfiguration {
    public let titleFont: Font
    public let subtitleFont: Font
    public let animationSize: CGSize
    public let spacing: CGFloat
    
    public init(
        titleFont: Font = TypographySystem.headline,
        subtitleFont: Font = TypographySystem.body,
        animationSize: CGSize = CGSize(width: 200, height: 200),
        spacing: CGFloat = 16
    ) {
        self.titleFont = titleFont
        self.subtitleFont = subtitleFont
        self.animationSize = animationSize
        self.spacing = spacing
    }
    
    public static let `default` = TailorStepConfiguration()
}
