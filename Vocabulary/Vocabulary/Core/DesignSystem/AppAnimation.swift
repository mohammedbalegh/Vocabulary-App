//
//  AppAnimation.swift
//  Vocabulary
//
//  Created by Mohammed Balegh on 08/09/2025.
//

import SwiftUI

/// Animation system providing consistent timing and easing across the app
/// Defines reusable animation configurations for different interaction types
public struct AnimationLibrary {
    
    // MARK: - Timing Constants
    private enum Timing {
        static let quick: Double = 0.1
        static let standard: Double = 0.3
        static let medium: Double = 0.4
        static let slow: Double = 0.5
        static let verySlow: Double = 0.8
    }
    
    // MARK: - Spring Configurations
    private enum SpringConfig {
        static let responsive = (response: 0.3, damping: 0.6)
        static let smooth = (response: 0.5, damping: 0.7)
        static let bouncy = (response: 0.8, damping: 0.6)
        static let gentle = (response: 0.6, damping: 0.8)
    }
    
    // MARK: - Standard Animations
    public static let fadeIn = Animation.easeOut(duration: Timing.medium)
    public static let fadeOut = Animation.easeIn(duration: Timing.standard)
    public static let slideIn = Animation.easeOut(duration: Timing.medium)
    public static let slideOut = Animation.easeIn(duration: Timing.standard)
    public static let defaultEaseOut = Animation.easeOut(duration: Timing.medium)
    public static let easeInOut = Animation.easeInOut(duration: Timing.standard)
    public static let spring = Animation.spring(
        response: SpringConfig.responsive.response,
        dampingFraction: SpringConfig.responsive.damping
    )
    
    // MARK: - Interactive Animations
    public static let buttonPress = Animation.easeIn(duration: Timing.quick)
    public static let buttonRelease = Animation.spring(
        response: SpringConfig.responsive.response,
        dampingFraction: SpringConfig.responsive.damping
    )
    public static let selection = Animation.easeInOut(duration: Timing.standard)
    
    // MARK: - Spring Animations
    public static let headerSpring = Animation.spring(
        response: SpringConfig.smooth.response,
        dampingFraction: SpringConfig.smooth.damping
    )
    public static let cardSpring = Animation.spring(
        response: SpringConfig.bouncy.response,
        dampingFraction: SpringConfig.bouncy.damping
    )
    public static let gentleSpring = Animation.spring(
        response: SpringConfig.gentle.response,
        dampingFraction: SpringConfig.gentle.damping
    )
    
    // MARK: - Specialized Animations
    public static let lottieEntry = Animation.spring(
        response: SpringConfig.bouncy.response,
        dampingFraction: SpringConfig.bouncy.damping
    )
    public static let contentReveal = Animation.easeOut(duration: Timing.medium)
    public static let pageTransition = Animation.easeInOut(duration: Timing.medium)
    
    // MARK: - Animation Builders
    public static func delayed(_ animation: Animation, by delay: Double) -> Animation {
        return animation.delay(delay)
    }
    
    public static func repeating(_ animation: Animation, count: Int = .max) -> Animation {
        return animation.repeatCount(count, autoreverses: true)
    }
    
    public static func customSpring(response: Double, damping: Double, blendDuration: Double = 0) -> Animation {
        return Animation.spring(response: response, dampingFraction: damping, blendDuration: blendDuration)
    }
    
    // MARK: - Accessibility Animations
    public static var reducedMotion: Animation {
        if UIAccessibility.isReduceMotionEnabled {
            return Animation.linear(duration: 0.1)
        }
        return fadeIn
    }
}

// MARK: - Backward Compatibility
public typealias AppAnimations = AnimationLibrary
