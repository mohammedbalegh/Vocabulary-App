//
//  ButtonAnimation.swift
//  Vocabulary
//
//  Created by Mohammed Balegh on 08/09/2025.
//

import SwiftUI

/// Button interaction animation constants and configurations
/// Provides consistent visual feedback for button press states
public struct InteractiveButtonConfig {
    
    // MARK: - Scale Transformations
    public enum ScalePresets {
        public static let normal: CGFloat = 1.0
        public static let pressed: CGFloat = 0.96
        public static let subtle: CGFloat = 0.98
        public static let strong: CGFloat = 0.94
    }
    
    // MARK: - Timing Configuration
    public enum TimingPresets {
        public static let pressDelay: TimeInterval = 0.15
        public static let releaseDelay: TimeInterval = 0.1
        public static let bounceDelay: TimeInterval = 0.2
    }
    
    // MARK: - Shadow Configurations
    public enum ShadowPresets {
        public static let normalOffset: CGFloat = 3
        public static let pressedOffset: CGFloat = 1
        public static let normalRadius: CGFloat = 2
        public static let pressedRadius: CGFloat = 0.5
    }
    
    // MARK: - Opacity Configurations
    public enum OpacityPresets {
        public static let normal: Double = 1.0
        public static let pressed: Double = 0.8
        public static let disabled: Double = 0.6
        public static let subtle: Double = 0.9
    }
    
    // MARK: - Animation Curves
    public enum AnimationCurves {
        public static let press = Animation.easeIn(duration: 0.1)
        public static let release = Animation.spring(response: 0.3, dampingFraction: 0.6)
        public static let bounce = Animation.spring(response: 0.4, dampingFraction: 0.5)
    }
    
    // MARK: - Convenience Methods
    public static func createPressAnimation(scale: CGFloat = ScalePresets.pressed) -> Animation {
        return AnimationCurves.press
    }
    
    public static func createReleaseAnimation() -> Animation {
        return AnimationCurves.release
    }
    
    public static func createBounceAnimation() -> Animation {
        return AnimationCurves.bounce
    }
}

// MARK: - Backward Compatibility
public typealias ButtonAnimation = InteractiveButtonConfig
