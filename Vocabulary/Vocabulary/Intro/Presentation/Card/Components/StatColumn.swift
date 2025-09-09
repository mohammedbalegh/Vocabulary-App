//
//  StatColumn.swift
//  Vocabulary
//
//  Created by Mohammed Balegh on 05/09/2025.
//

import SwiftUI

// MARK: - Stat Column Configuration
public struct StatColumnConfiguration {
    public let titleFontSize: CGFloat
    public let titleFontWeight: Font.Weight
    public let titleColor: Color
    public let subtitleFontSize: CGFloat
    public let subtitleFontWeight: Font.Weight
    public let subtitleColor: Color
    public let spacing: CGFloat
    public let alignment: HorizontalAlignment
    
    public init(
        titleFontSize: CGFloat = 18,
        titleFontWeight: Font.Weight = .bold,
        titleColor: Color = AppColorPalette.textPrimary,
        subtitleFontSize: CGFloat = 12,
        subtitleFontWeight: Font.Weight = .regular,
        subtitleColor: Color = Color(.systemGray),
        spacing: CGFloat = 2,
        alignment: HorizontalAlignment = .center
    ) {
        self.titleFontSize = titleFontSize
        self.titleFontWeight = titleFontWeight
        self.titleColor = titleColor
        self.subtitleFontSize = subtitleFontSize
        self.subtitleFontWeight = subtitleFontWeight
        self.subtitleColor = subtitleColor
        self.spacing = spacing
        self.alignment = alignment
    }
    
    public static let `default` = StatColumnConfiguration()
    public static let compact = StatColumnConfiguration(
        titleFontSize: 16,
        subtitleFontSize: 10,
        spacing: 1
    )
    public static let prominent = StatColumnConfiguration(
        titleFontSize: 20,
        subtitleFontSize: 14,
        spacing: 4
    )
}

// MARK: - Stat Column
public struct StatColumn: View {
    public let title: String
    public let subtitle: String
    public let configuration: StatColumnConfiguration
    
    public init(
        title: String,
        subtitle: String,
        configuration: StatColumnConfiguration = .default
    ) {
        self.title = title
        self.subtitle = subtitle
        self.configuration = configuration
    }
    
    public var body: some View {
        VStack(spacing: configuration.spacing) {
            Text(title)
                .font(.system(size: configuration.titleFontSize, weight: configuration.titleFontWeight))
                .foregroundStyle(configuration.titleColor)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            
            Text(subtitle)
                .font(.system(size: configuration.subtitleFontSize, weight: configuration.subtitleFontWeight))
                .foregroundStyle(configuration.subtitleColor)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
                .multilineTextAlignment(.center)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title) \(subtitle)")
    }
}

// MARK: - Convenience Extensions
public extension StatColumn {
    /// Create a compact stat column
    static func compact(title: String, subtitle: String) -> StatColumn {
        StatColumn(
            title: title,
            subtitle: subtitle,
            configuration: .compact
        )
    }
    
    /// Create a prominent stat column
    static func prominent(title: String, subtitle: String) -> StatColumn {
        StatColumn(
            title: title,
            subtitle: subtitle,
            configuration: .prominent
        )
    }
}
