//
//  AppTypography.swift
//  Vocabulary
//
//  Created by Mohammed Balegh on 08/09/2025.
//

import SwiftUI

/// Typography system for consistent text styling across the app
/// Defines font sizes, weights, and styles following design system principles
public struct TypographySystem {
    
    // MARK: - Font Size Constants
    private enum FontSizes {
        static let largeTitle: CGFloat = 28
        static let title: CGFloat = 26
        static let body: CGFloat = 16
        static let button: CGFloat = 14
        static let caption: CGFloat = 12
        static let small: CGFloat = 10
    }
    
    // MARK: - Primary Typography Styles
    public static let largeTitle = Font.system(size: FontSizes.largeTitle, weight: .semibold, design: .default)
    public static let title = Font.system(size: FontSizes.title, weight: .semibold, design: .default)
    public static let headline = Font.system(size: 20, weight: .semibold, design: .default)
    public static let body = Font.system(size: FontSizes.body, weight: .regular, design: .default)
    public static let button = Font.system(size: FontSizes.button, weight: .bold, design: .default)
    public static let caption = Font.system(size: FontSizes.caption, weight: .medium, design: .default)
    public static let small = Font.system(size: FontSizes.small, weight: .regular, design: .default)
    
    // MARK: - Weighted Variations
    public static let bodyBold = Font.system(size: FontSizes.body, weight: .bold, design: .default)
    public static let bodyMedium = Font.system(size: FontSizes.body, weight: .medium, design: .default)
    public static let titleBold = Font.system(size: FontSizes.title, weight: .bold, design: .default)
    
    // MARK: - Specialized Fonts
    public static let headerFont = largeTitle
    public static let cardTitle = Font.system(size: 24, weight: .bold, design: .rounded)
    public static let cardSubtitle = Font.system(size: 18, weight: .medium, design: .default)
    public static let progressText = Font.system(size: FontSizes.caption, weight: .medium, design: .default)
    
    // MARK: - Accessibility Support
    public static func scaledFont(_ baseFont: Font, for category: ContentSizeCategory = .medium) -> Font {
        // For now, return the base font as Font doesn't have direct size manipulation
        // In a real implementation, you would need to extract the size and recreate the font
        return baseFont
    }
    
    // MARK: - Dynamic Font Creation
    public static func createFont(size: CGFloat, weight: Font.Weight = .regular, design: Font.Design = .default) -> Font {
        return Font.system(size: size, weight: weight, design: design)
    }
    
    public static func scaledFont(size: CGFloat, weight: Font.Weight = .regular, design: Font.Design = .default, for category: ContentSizeCategory = .medium) -> Font {
        let scaledSize = size * scaleFactor(for: category)
        return createFont(size: scaledSize, weight: weight, design: design)
    }
    
    private static func scaleFactor(for category: ContentSizeCategory) -> CGFloat {
        switch category {
        case .extraSmall: return 0.8
        case .small: return 0.9
        case .medium: return 1.0
        case .large: return 1.1
        case .extraLarge: return 1.2
        case .extraExtraLarge: return 1.3
        case .extraExtraExtraLarge: return 1.4
        case .accessibilityMedium: return 1.5
        case .accessibilityLarge: return 1.6
        case .accessibilityExtraLarge: return 1.7
        case .accessibilityExtraExtraLarge: return 1.8
        case .accessibilityExtraExtraExtraLarge: return 1.9
        @unknown default: return 1.0
        }
    }
}

// MARK: - Backward Compatibility
public typealias AppTypography = TypographySystem
