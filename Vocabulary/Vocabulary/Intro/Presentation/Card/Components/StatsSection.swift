//
//  StatsSection.swift
//  Vocabulary
//
//  Created by Mohammed Balegh on 05/09/2025.
//

import SwiftUI

// MARK: - Stats Configuration
public struct StatsConfiguration {
    public let spacing: CGFloat
    public let horizontalPadding: CGFloat
    public let animationDelay: Double
    public let animationDuration: Double
    
    public init(
        spacing: CGFloat = 12,
        horizontalPadding: CGFloat = 16,
        animationDelay: Double = 0.3,
        animationDuration: Double = 0.6
    ) {
        self.spacing = spacing
        self.horizontalPadding = horizontalPadding
        self.animationDelay = animationDelay
        self.animationDuration = animationDuration
    }
    
    public static let `default` = StatsConfiguration()
    public static let compact = StatsConfiguration(
        spacing: 8,
        horizontalPadding: 12
    )
    public static let spacious = StatsConfiguration(
        spacing: 16,
        horizontalPadding: 20
    )
}

// MARK: - Stats Section
public struct StatsSection: View {
    public let configuration: StatsConfiguration
    @State private var isVisible = false
    
    public init(configuration: StatsConfiguration = .default) {
        self.configuration = configuration
    }
    
    public var body: some View {
        HStack(spacing: configuration.spacing) {
            Spacer()
            
            StatColumn(
                title: "350 million",
                subtitle: "words learned",
                configuration: .default
            )
            
            RatingColumn()
            
            StatColumn(
                title: "10 million",
                subtitle: "downloads",
                configuration: .default
            )
            
            Spacer()
        }
        .padding(.horizontal, configuration.horizontalPadding)
        .opacity(isVisible ? 1 : 0)
        .offset(y: isVisible ? 0 : 20)
        .animation(
            .easeOut(duration: configuration.animationDuration)
                .delay(configuration.animationDelay),
            value: isVisible
        )
        .onAppear {
            isVisible = true
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("App statistics and ratings")
    }
}

// MARK: - Convenience Extensions
public extension StatsSection {
    /// Create a compact stats section
    static func compact() -> StatsSection {
        StatsSection(configuration: .compact)
    }
    
    /// Create a spacious stats section
    static func spacious() -> StatsSection {
        StatsSection(configuration: .spacious)
    }
}


