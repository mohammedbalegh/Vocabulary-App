//
//  HeaderTextSection.swift
//  Vocabulary
//
//  Created by Mohammed Balegh on 05/09/2025.
//

import SwiftUI

// MARK: - Header Text Configuration
public struct HeaderTextConfiguration {
    public let titleText: String
    public let fontSize: CGFloat
    public let fontWeight: Font.Weight
    public let textColor: Color
    public let shadowRadius: CGFloat
    public let shadowOffset: CGPoint
    public let shadowColor: Color
    public let shadowOpacity: Double
    public let horizontalPadding: CGFloat
    public let animationDuration: Double
    public let initialOffset: CGFloat
    
    public init(
        titleText: String = "Expand Your Vocabulary in 1 minute a day",
        fontSize: CGFloat = 28,
        fontWeight: Font.Weight = .bold,
        textColor: Color = AppColorPalette.textPrimary,
        shadowRadius: CGFloat = 4,
        shadowOffset: CGPoint = CGPoint(x: 2, y: 2),
        shadowColor: Color = .black,
        shadowOpacity: Double = 0.3,
        horizontalPadding: CGFloat = 8,
        animationDuration: Double = 0.9,
        initialOffset: CGFloat = -250
    ) {
        self.titleText = titleText
        self.fontSize = fontSize
        self.fontWeight = fontWeight
        self.textColor = textColor
        self.shadowRadius = shadowRadius
        self.shadowOffset = shadowOffset
        self.shadowColor = shadowColor
        self.shadowOpacity = shadowOpacity
        self.horizontalPadding = horizontalPadding
        self.animationDuration = animationDuration
        self.initialOffset = initialOffset
    }
    
    public static let `default` = HeaderTextConfiguration()
    public static let compact = HeaderTextConfiguration(
        fontSize: 24,
        horizontalPadding: 6
    )
    public static let spacious = HeaderTextConfiguration(
        fontSize: 32,
        horizontalPadding: 12
    )
}

// MARK: - Header Text Section
public struct HeaderTextSection: View {
    public let isTextVisible: Bool
    public let configuration: HeaderTextConfiguration
    
    public init(
        isTextVisible: Bool,
        configuration: HeaderTextConfiguration = .default
    ) {
        self.isTextVisible = isTextVisible
        self.configuration = configuration
    }
    
    public var body: some View {
        Text(configuration.titleText)
            .font(.system(size: adaptiveFontSize, weight: configuration.fontWeight))
            .foregroundStyle(configuration.textColor)
            .multilineTextAlignment(.center)
            .lineLimit(nil)
            .fixedSize(horizontal: false, vertical: true)
            .shadow(
                color: configuration.shadowColor.opacity(configuration.shadowOpacity),
                radius: configuration.shadowRadius,
                x: configuration.shadowOffset.x,
                y: configuration.shadowOffset.y
            )
            .offset(x: isTextVisible ? 0 : configuration.initialOffset)
            .animation(.easeOut(duration: configuration.animationDuration), value: isTextVisible)
            .padding(.horizontal, configuration.horizontalPadding)
            .accessibilityLabel("Main headline: \(configuration.titleText)")
            .accessibilityAddTraits(.isHeader)
    }
    
    private var adaptiveFontSize: CGFloat {
        if DeviceLayoutManager.isCompactHeight {
            return configuration.fontSize * 0.85
        } else {
            return configuration.fontSize
        }
    }
}

// MARK: - Convenience Extensions
public extension HeaderTextSection {
    /// Create a compact header text section
    static func compact(isTextVisible: Bool) -> HeaderTextSection {
        HeaderTextSection(
            isTextVisible: isTextVisible,
            configuration: .compact
        )
    }
    
    /// Create a spacious header text section
    static func spacious(isTextVisible: Bool) -> HeaderTextSection {
        HeaderTextSection(
            isTextVisible: isTextVisible,
            configuration: .spacious
        )
    }
}
