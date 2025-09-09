//
//  RatingColumn.swift
//  Vocabulary
//
//  Created by Mohammed Balegh on 05/09/2025.
//

import SwiftUI

// MARK: - Rating Configuration
public struct RatingConfiguration {
    public let rating: Double
    public let maxRating: Int
    public let ratingFontSize: CGFloat
    public let ratingFontWeight: Font.Weight
    public let ratingColor: Color
    public let starSize: CGFloat
    public let starSpacing: CGFloat
    public let starColor: Color
    public let wheatImageSize: CGSize
    public let wheatColor: Color
    public let verticalSpacing: CGFloat
    
    public init(
        rating: Double = 4.8,
        maxRating: Int = 5,
        ratingFontSize: CGFloat = 22,
        ratingFontWeight: Font.Weight = .bold,
        ratingColor: Color = AppColorPalette.textPrimary,
        starSize: CGFloat = 8,
        starSpacing: CGFloat = 4,
        starColor: Color = .yellow,
        wheatImageSize: CGSize = CGSize(width: 17, height: 40),
        wheatColor: Color = .white,
        verticalSpacing: CGFloat = 2
    ) {
        self.rating = rating
        self.maxRating = maxRating
        self.ratingFontSize = ratingFontSize
        self.ratingFontWeight = ratingFontWeight
        self.ratingColor = ratingColor
        self.starSize = starSize
        self.starSpacing = starSpacing
        self.starColor = starColor
        self.wheatImageSize = wheatImageSize
        self.wheatColor = wheatColor
        self.verticalSpacing = verticalSpacing
    }
    
    public static let `default` = RatingConfiguration()
    public static let compact = RatingConfiguration(
        ratingFontSize: 18,
        starSize: 6,
        starSpacing: 2,
        wheatImageSize: CGSize(width: 14, height: 32)
    )
    public static let prominent = RatingConfiguration(
        ratingFontSize: 26,
        starSize: 10,
        starSpacing: 6,
        wheatImageSize: CGSize(width: 20, height: 48)
    )
}

// MARK: - Rating Column
public struct RatingColumn: View {
    public let configuration: RatingConfiguration
    
    public init(configuration: RatingConfiguration = .default) {
        self.configuration = configuration
    }
    
    public var body: some View {
        HStack(spacing: 0) {
            wheatImage(isFlipped: true)
            
            VStack(spacing: configuration.verticalSpacing) {
                ratingText
                starRating
            }
            
            wheatImage(isFlipped: false)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("App rating: \(configuration.rating) out of \(configuration.maxRating) stars")
    }
    
    private var ratingText: some View {
        Text(String(format: "%.1f", configuration.rating))
            .fixedSize()
            .lineLimit(1)
            .font(.system(size: configuration.ratingFontSize, weight: configuration.ratingFontWeight))
            .foregroundStyle(configuration.ratingColor)
    }
    
    private var starRating: some View {
        HStack(spacing: configuration.starSpacing) {
            ForEach(0..<configuration.maxRating, id: \.self) { index in
                Image(systemName: "star.fill")
                    .resizable()
                    .foregroundStyle(configuration.starColor)
                    .frame(width: configuration.starSize, height: configuration.starSize)
            }
        }
    }
    
    private func wheatImage(isFlipped: Bool) -> some View {
        Image("wheat")
            .resizable()
            .renderingMode(.template)
            .foregroundStyle(configuration.wheatColor)
            .frame(
                width: configuration.wheatImageSize.width,
                height: configuration.wheatImageSize.height
            )
            .scaleEffect(x: isFlipped ? -1 : 1, y: 1)
    }
}

// MARK: - Convenience Extensions
public extension RatingColumn {
    /// Create a compact rating column
    static func compact() -> RatingColumn {
        RatingColumn(configuration: .compact)
    }
    
    /// Create a prominent rating column
    static func prominent() -> RatingColumn {
        RatingColumn(configuration: .prominent)
    }
}
