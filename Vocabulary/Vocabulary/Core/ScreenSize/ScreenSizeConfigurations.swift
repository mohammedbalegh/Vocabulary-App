//
//  ScreenSizeConfigurations.swift
//  Vocabulary
//
//  Created by Mohammed Balegh on 08/09/2025.
//

import SwiftUI

/// Device screen size detection and responsive design utilities
/// Provides adaptive layouts based on device dimensions and capabilities
public struct DeviceLayoutManager {
    
    // MARK: - Screen Dimension Thresholds
    private enum ScreenThresholds {
        static let compactHeight: CGFloat = 667  // iPhone SE, 8, etc.
        static let compactWidth: CGFloat = 375   // iPhone SE, 8, etc.
        static let regularHeight: CGFloat = 812  // iPhone X and newer
        static let regularWidth: CGFloat = 414   // iPhone Plus models
    }
    
    // MARK: - Device Classification
    public enum DeviceCategory {
        case compact
        case regular
        case large
    }
    
    // MARK: - Screen Size Detection
    public static var currentScreenBounds: CGRect {
        return UIScreen.main.bounds
    }
    
    public static var screenWidth: CGFloat {
        return currentScreenBounds.width
    }
    
    public static var screenHeight: CGFloat {
        return currentScreenBounds.height
    }
    
    // MARK: - Device Type Detection
    public static var isCompactHeight: Bool {
        return screenHeight <= ScreenThresholds.compactHeight
    }
    
    public static var isCompactWidth: Bool {
        return screenWidth <= ScreenThresholds.compactWidth
    }
    
    public static var isRegularHeight: Bool {
        return screenHeight > ScreenThresholds.compactHeight && screenHeight <= ScreenThresholds.regularHeight
    }
    
    public static var isRegularWidth: Bool {
        return screenWidth > ScreenThresholds.compactWidth && screenWidth <= ScreenThresholds.regularWidth
    }
    
    public static var isLargeScreen: Bool {
        return screenHeight > ScreenThresholds.regularHeight || screenWidth > ScreenThresholds.regularWidth
    }
    
    // MARK: - Device Category
    public static var deviceCategory: DeviceCategory {
        if isCompactHeight || isCompactWidth {
            return .compact
        } else if isLargeScreen {
            return .large
        } else {
            return .regular
        }
    }
    
    // MARK: - Responsive Values
    public static func adaptiveValue<T>(compact: T, regular: T, large: T) -> T {
        switch deviceCategory {
        case .compact:
            return compact
        case .regular:
            return regular
        case .large:
            return large
        }
    }
    
    public static func adaptiveValue<T>(compact: T, regular: T) -> T {
        return isCompactHeight ? compact : regular
    }
    
    // MARK: - Safe Area Utilities
    public static var hasNotch: Bool {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            return window.safeAreaInsets.top > 20
        }
        return false
    }
    
    public static var safeAreaInsets: UIEdgeInsets {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            return window.safeAreaInsets
        }
        return .zero
    }
}

// MARK: - Backward Compatibility
public typealias ScreenSizeConfiguration = DeviceLayoutManager
