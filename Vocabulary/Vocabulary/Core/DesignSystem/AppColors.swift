//
//  AppColors.swift
//  Vocabulary
//
//  Created by Mohammed Balegh on 08/09/2025.
//

import SwiftUI

/// Centralized color palette for the Vocabulary app
/// Provides consistent theming across all UI components
public struct AppColorPalette {
    
    // MARK: - Primary Colors
    public static let mainBackground = Color(hexString: "4b4841")
    public static let actionButton = Color(hexString: "c17070")
    public static let textPrimary = Color.white
    public static let highlightAccent = Color(hexString: "faf5e8")
    
    // MARK: - Secondary Colors
    public static let borderSubtle = Color.white.opacity(0.15)
    public static let shadowDefault = Color.black.opacity(0.4)
    public static let shadowPressed = Color.black.opacity(0.2)
    public static let buttonSecondary = Color(hexString: "#2D2B26")
    public static let cardBackground = Color(hexString: "34322D")
    public static let textSecondary = Color.white.opacity(0.7)
    public static let surface = Color(hexString: "2D2B26")
    
    // MARK: - Semantic Color Aliases (for backward compatibility)
    public static var background: Color { mainBackground }
    public static var primaryButton: Color { actionButton }
    public static var primaryText: Color { textPrimary }
    public static var accent: Color { highlightAccent }
    public static var border: Color { borderSubtle }
    public static var shadow: Color { shadowDefault }
    public static var pressedShadow: Color { shadowPressed }
    public static var optionButtonColor: Color { buttonSecondary }
    public static var cardColor: Color { cardBackground }
}

// MARK: - Color Extension for Hex Support
public extension Color {
    
    /// Initializes a Color from a hexadecimal string representation
    /// - Parameter hexString: Hex string in formats: "RRGGBB", "#RRGGBB", "AARRGGBB", "#AARRGGBB"
    /// - Returns: Color instance or white if parsing fails
    init(hexString: String) {
        let sanitizedHex = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "#", with: "")
        
        guard !sanitizedHex.isEmpty else {
            self.init(.sRGB, red: 1, green: 1, blue: 1, opacity: 1)
            return
        }
        
        var hexValue: UInt64 = 0
        Scanner(string: sanitizedHex).scanHexInt64(&hexValue)
        
        let (red, green, blue, alpha) = Self.parseHexComponents(from: hexValue, length: sanitizedHex.count)
        
        self.init(
            .sRGB,
            red: Double(red) / 255.0,
            green: Double(green) / 255.0,
            blue: Double(blue) / 255.0,
            opacity: Double(alpha) / 255.0
        )
    }
    
    /// Parses hex components based on string length
    /// - Parameters:
    ///   - hexValue: The parsed hex integer value
    ///   - length: Length of the original hex string
    /// - Returns: Tuple of (red, green, blue, alpha) components
    private static func parseHexComponents(from hexValue: UInt64, length: Int) -> (UInt64, UInt64, UInt64, UInt64) {
        switch length {
        case 8: // AARRGGBB format
            return (
                (hexValue >> 16) & 0xFF,  // Red
                (hexValue >> 8) & 0xFF,   // Green
                hexValue & 0xFF,          // Blue
                (hexValue >> 24) & 0xFF   // Alpha
            )
        case 6: // RRGGBB format
            return (
                (hexValue >> 16) & 0xFF,  // Red
                (hexValue >> 8) & 0xFF,   // Green
                hexValue & 0xFF,          // Blue
                0xFF                      // Alpha (fully opaque)
            )
        default: // Invalid format - return white
            return (0xFF, 0xFF, 0xFF, 0xFF)
        }
    }
}

// MARK: - Backward Compatibility
public typealias AppColors = AppColorPalette

