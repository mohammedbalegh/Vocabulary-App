//
//  OnboardingStep.swift
//  Vocabulary
//
//  Created by Mohammed Balegh on 06/09/2025.
//

import Foundation
import SwiftUI

/// Represents a step in the onboarding flow with comprehensive configuration
public enum OnboardingStep: Int, CaseIterable, Identifiable, Hashable, Codable {
    case referral = 0
    case tailor = 1
    case age = 2
    case gender = 3
    case nameInput = 4
    case goals = 5
    case topics = 6
    case done = 7
    
    public var id: Int { rawValue }
    
    /// Human-readable title for the step
    public var title: String {
        switch self {
        case .referral:
            return "How did you hear about Vocabulary?"
        case .tailor:
            return "Tailor your words recommendations"
        case .age:
            return "What is your age group?"
        case .gender:
            return "What is your gender?"
        case .nameInput:
            return "What do you want to be called?"
        case .goals:
            return "Do you have a specific goal in mind?"
        case .topics:
            return "Which topics are you interested in?"
        case .done:
            return "Welcome to Vocabulary"
        }
    }
    
    /// Optional subtitle for additional context
    public var subtitle: String? {
        switch self {
        case .referral:
            return "Help us understand how you discovered our app"
        case .tailor:
            return "We'll customize your learning experience"
        case .age:
            return "This helps us recommend age-appropriate content"
        case .gender:
            return "Optional - helps us personalize your experience"
        case .nameInput:
            return "We'll use this to personalize your learning journey"
        case .goals:
            return "Select all that apply to your learning objectives"
        case .topics:
            return "Choose topics that interest you most"
        case .done:
            return "You're all set to start learning!"
        }
    }
    
    /// Animation file name for this step
    public var animationName: String? {
        switch self {
        case .tailor:
            return "Girl with books"
        case .done:
            return "done.json"
        default:
            return nil
        }
    }
    
    /// Step type for UI configuration
    public var stepType: OnboardingStepType {
        switch self {
        case .referral, .age, .gender:
            return .singleSelection
        case .tailor, .done:
            return .information
        case .nameInput:
            return .textInput
        case .goals, .topics:
            return .multiSelection
        }
    }
    
    /// Whether this step can be skipped
    public var allowsSkip: Bool {
        switch self {
        case .nameInput, .goals, .topics:
            return true
        default:
            return false
        }
    }
    
    /// Whether this step is required for completion
    public var isRequired: Bool {
        switch self {
        case .referral, .age, .gender:
            return true
        case .nameInput, .goals, .topics:
            return false
        case .tailor, .done:
            return true
        }
    }
    
    /// Estimated completion time in seconds
    public var estimatedDuration: TimeInterval {
        switch self {
        case .referral, .age, .gender:
            return 30.0
        case .tailor, .done:
            return 10.0
        case .nameInput:
            return 45.0
        case .goals, .topics:
            return 60.0
        }
    }
    
    /// Progress percentage for this step (0.0 to 1.0)
    public var progressPercentage: Double {
        return Double(rawValue) / Double(OnboardingStep.allCases.count - 1)
    }
    
    /// Next step in the flow
    public var next: OnboardingStep? {
        guard let currentIndex = OnboardingStep.allCases.firstIndex(of: self),
              currentIndex < OnboardingStep.allCases.count - 1 else {
            return nil
        }
        return OnboardingStep.allCases[currentIndex + 1]
    }
    
    /// Previous step in the flow
    public var previous: OnboardingStep? {
        guard let currentIndex = OnboardingStep.allCases.firstIndex(of: self),
              currentIndex > 0 else {
            return nil
        }
        return OnboardingStep.allCases[currentIndex - 1]
    }
    
    /// Validation rules for this step
    public var validationRules: [OnboardingValidationRule] {
        switch self {
        case .referral, .age, .gender:
            return [.required]
        case .nameInput:
            return [.optional, .maxLength(50)]
        case .goals, .topics:
            return [.optional, .minSelections(0), .maxSelections(5)]
        case .tailor, .done:
            return []
        }
    }
}

/// Types of onboarding steps for UI configuration
public enum OnboardingStepType: String, CaseIterable, Codable {
    case singleSelection = "single_selection"
    case multiSelection = "multi_selection"
    case textInput = "text_input"
    case information = "information"
}

/// Validation rules for onboarding steps
public enum OnboardingValidationRule: Equatable, Codable {
    case required
    case optional
    case maxLength(Int)
    case minLength(Int)
    case minSelections(Int)
    case maxSelections(Int)
    case custom(String)
}

/// Configuration for onboarding flow
public struct OnboardingFlowConfiguration: Codable {
    public let enableAnimations: Bool
    public let enableHapticFeedback: Bool
    public let enableAnalytics: Bool
    public let autoAdvanceDelay: TimeInterval
    public let allowBackNavigation: Bool
    public let showProgressIndicator: Bool
    public let theme: OnboardingTheme
    
    public init(
        enableAnimations: Bool = true,
        enableHapticFeedback: Bool = true,
        enableAnalytics: Bool = true,
        autoAdvanceDelay: TimeInterval = 0.0,
        allowBackNavigation: Bool = true,
        showProgressIndicator: Bool = true,
        theme: OnboardingTheme = .default
    ) {
        self.enableAnimations = enableAnimations
        self.enableHapticFeedback = enableHapticFeedback
        self.enableAnalytics = enableAnalytics
        self.autoAdvanceDelay = autoAdvanceDelay
        self.allowBackNavigation = allowBackNavigation
        self.showProgressIndicator = showProgressIndicator
        self.theme = theme
    }
    
    public static let `default` = OnboardingFlowConfiguration()
}

/// Theme configuration for onboarding
public enum OnboardingTheme: String, CaseIterable, Codable {
    case `default` = "default"
    case minimal = "minimal"
    case colorful = "colorful"
    case dark = "dark"
}

/// Statistics for onboarding completion
public struct OnboardingStatistics: Codable {
    public let totalSteps: Int
    public let completedSteps: Int
    public let skippedSteps: Int
    public let totalTimeSpent: TimeInterval
    public let averageTimePerStep: TimeInterval
    public let completionRate: Double
    
    public init(
        totalSteps: Int,
        completedSteps: Int,
        skippedSteps: Int,
        totalTimeSpent: TimeInterval
    ) {
        self.totalSteps = totalSteps
        self.completedSteps = completedSteps
        self.skippedSteps = skippedSteps
        self.totalTimeSpent = totalTimeSpent
        self.averageTimePerStep = totalTimeSpent / Double(max(completedSteps, 1))
        self.completionRate = Double(completedSteps) / Double(totalSteps)
    }
}

// MARK: - Convenience Extensions
public extension OnboardingStep {
    /// Check if this step is the first step
    var isFirst: Bool { self == .referral }
    
    /// Check if this step is the last step
    var isLast: Bool { self == .done }
    
    /// Get all steps before this one
    var previousSteps: [OnboardingStep] {
        guard let index = OnboardingStep.allCases.firstIndex(of: self) else { return [] }
        return Array(OnboardingStep.allCases.prefix(index))
    }
    
    /// Get all steps after this one
    var nextSteps: [OnboardingStep] {
        guard let index = OnboardingStep.allCases.firstIndex(of: self) else { return [] }
        return Array(OnboardingStep.allCases.dropFirst(index + 1))
    }
    
    /// Get step by index safely
    static func step(at index: Int) -> OnboardingStep? {
        guard index >= 0 && index < allCases.count else { return nil }
        return allCases[index]
    }
    
    /// Get index of this step
    var index: Int {
        return OnboardingStep.allCases.firstIndex(of: self) ?? 0
    }
}
