//
//  IntroItem.swift
//  Vocabulary
//
//  Created by Mohammed Balegh on 05/09/2025.
//

import SwiftUI

/// Represents an introduction item with comprehensive styling and content information
/// Provides structured data for introduction screen display and animations
public struct IntroItem: Identifiable, Hashable, Codable {
    
    // MARK: - Core Properties
    public let id: UUID
    public let text: String
    public let textColor: String
    public let circleColor: String
    public let backgroundColor: String
    public let displayOrder: Int
    public let isActive: Bool
    public let createdAt: Date
    public let updatedAt: Date
    
    // MARK: - Initialization
    public init(
        text: String,
        textColor: String,
        circleColor: String,
        backgroundColor: String,
        displayOrder: Int = 0,
        isActive: Bool = true,
        id: UUID = UUID(),
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.text = text
        self.textColor = textColor
        self.circleColor = circleColor
        self.backgroundColor = backgroundColor
        self.displayOrder = displayOrder
        self.isActive = isActive
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    // MARK: - Computed Properties
    public var displayText: String {
        return text.capitalized
    }
    
    public var textColorValue: Color {
        return Color(hexString: textColor)
    }
    
    public var circleColorValue: Color {
        return Color(hexString: circleColor)
    }
    
    public var backgroundColorValue: Color {
        return Color(hexString: backgroundColor)
    }
    
    public var isValid: Bool {
        return !text.isEmpty &&
               !textColor.isEmpty &&
               !circleColor.isEmpty &&
               !backgroundColor.isEmpty &&
               text.count >= 2 &&
               text.count <= 100
    }
    
    public var validationErrors: [String] {
        var errors: [String] = []
        
        if text.isEmpty {
            errors.append("Text cannot be empty")
        } else if text.count < 2 {
            errors.append("Text must be at least 2 characters")
        } else if text.count > 100 {
            errors.append("Text must be less than 100 characters")
        }
        
        if textColor.isEmpty {
            errors.append("Text color cannot be empty")
        }
        
        if circleColor.isEmpty {
            errors.append("Circle color cannot be empty")
        }
        
        if backgroundColor.isEmpty {
            errors.append("Background color cannot be empty")
        }
        
        return errors
    }
}

// MARK: - Supporting Types
public enum IntroItemType: String, CaseIterable, Codable {
    case headline = "headline"
    case feature = "feature"
    case statistic = "statistic"
    case callToAction = "callToAction"
    
    public var displayName: String {
        return rawValue.capitalized
    }
    
    public var icon: String {
        switch self {
        case .headline: return "text.bubble"
        case .feature: return "star.fill"
        case .statistic: return "chart.bar.fill"
        case .callToAction: return "arrow.right.circle.fill"
        }
    }
}

// MARK: - Convenience Extensions
public extension IntroItem {
    /// Create an intro item with Color objects (converts to hex strings)
    static func create(
        text: String,
        textColor: Color,
        circleColor: Color,
        backgroundColor: Color,
        displayOrder: Int = 0,
        isActive: Bool = true
    ) -> IntroItem {
        return IntroItem(
            text: text,
            textColor: textColor.toHexString(),
            circleColor: circleColor.toHexString(),
            backgroundColor: backgroundColor.toHexString(),
            displayOrder: displayOrder,
            isActive: isActive
        )
    }
}

// MARK: - Color Extension for Hex Conversion
private extension Color {
    func toHexString() -> String {
        let uiColor = UIColor(self)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        let rgb: Int = (Int)(red * 255) << 16 | (Int)(green * 255) << 8 | (Int)(blue * 255) << 0
        
        return String(format: "#%06x", rgb)
    }
}
