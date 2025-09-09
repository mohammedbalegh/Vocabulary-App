//
//  SubtitleSection.swift
//  Vocabulary
//
//  Created by Mohammed Balegh on 05/09/2025.
//

import SwiftUI

// MARK: - Subtitle Configuration
public struct SubtitleConfiguration {
    public let subtitleText: String
    public let fontSize: CGFloat
    public let fontWeight: Font.Weight
    public let textColor: Color
    public let horizontalPadding: CGFloat
    public let lineSpacing: CGFloat
    
    public init(
        subtitleText: String = "Learn 10,000+ new words with a new daily habit that takes just 1 minute",
        fontSize: CGFloat = 16,
        fontWeight: Font.Weight = .regular,
        textColor: Color = Color(.systemGray),
        horizontalPadding: CGFloat = 16,
        lineSpacing: CGFloat = 2
    ) {
        self.subtitleText = subtitleText
        self.fontSize = fontSize
        self.fontWeight = fontWeight
        self.textColor = textColor
        self.horizontalPadding = horizontalPadding
        self.lineSpacing = lineSpacing
    }
    
    public static let `default` = SubtitleConfiguration()
    public static let compact = SubtitleConfiguration(
        fontSize: 14,
        horizontalPadding: 12
    )
    public static let spacious = SubtitleConfiguration(
        fontSize: 18,
        horizontalPadding: 20
    )
}

// MARK: - Subtitle Section
public struct SubtitleSection: View {
    public let configuration: SubtitleConfiguration
    
    public init(configuration: SubtitleConfiguration = .default) {
        self.configuration = configuration
    }
    
    public var body: some View {
        Text(configuration.subtitleText)
            .font(.system(size: configuration.fontSize, weight: configuration.fontWeight))
            .foregroundStyle(configuration.textColor)
            .multilineTextAlignment(.center)
            .lineLimit(nil)
            .fixedSize(horizontal: false, vertical: true)
            .lineSpacing(configuration.lineSpacing)
            .padding(.horizontal, configuration.horizontalPadding)
            .accessibilityLabel("Description: \(configuration.subtitleText)")
    }
}

// MARK: - Convenience Extensions
public extension SubtitleSection {
    /// Create a compact subtitle section
    static func compact() -> SubtitleSection {
        SubtitleSection(configuration: .compact)
    }
    
    /// Create a spacious subtitle section
    static func spacious() -> SubtitleSection {
        SubtitleSection(configuration: .spacious)
    }
}
