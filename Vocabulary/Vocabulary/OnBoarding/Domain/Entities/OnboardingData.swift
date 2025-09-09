//
//  OnboardingData.swift
//  Vocabulary
//
//  Created by Mohammed Balegh on 06/09/2025.
//

import Foundation
import SwiftUI

/// Comprehensive onboarding data entity with validation and metadata
public struct OnboardingData: Identifiable, Equatable, Hashable, Codable {
    public let id: UUID
    public var referral: Referral?
    public var ageRange: AgeRange?
    public var gender: GenderOptions?
    public var name: String?
    public var goals: Set<GoalsOptions>
    public var topics: Set<TopicsOptions>
    public var completedAt: Date?
    public let createdAt: Date
    public var updatedAt: Date
    public var version: String
    public var deviceInfo: DeviceInfo?
    public var userPreferences: UserPreferences
    
    public init(
        id: UUID = UUID(),
        referral: Referral? = nil,
        ageRange: AgeRange? = nil,
        gender: GenderOptions? = nil,
        name: String? = nil,
        goals: Set<GoalsOptions> = [],
        topics: Set<TopicsOptions> = [],
        completedAt: Date? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        version: String = "1.0",
        deviceInfo: DeviceInfo? = nil,
        userPreferences: UserPreferences = UserPreferences()
    ) {
        self.id = id
        self.referral = referral
        self.ageRange = ageRange
        self.gender = gender
        self.name = name
        self.goals = goals
        self.topics = topics
        self.completedAt = completedAt
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.version = version
        self.deviceInfo = deviceInfo
        self.userPreferences = userPreferences
    }
    
    /// Check if onboarding is complete
    public var isComplete: Bool {
        return completedAt != nil
    }
    
    /// Check if all required fields are filled
    public var isRequiredDataComplete: Bool {
        return referral != nil && ageRange != nil && gender != nil
    }
    
    /// Calculate completion percentage
    public var completionPercentage: Double {
        let totalFields = 7.0 // referral, age, gender, name, goals, topics, completion
        var completedFields = 0.0
        
        if referral != nil { completedFields += 1 }
        if ageRange != nil { completedFields += 1 }
        if gender != nil { completedFields += 1 }
        if name != nil && !name!.isEmpty { completedFields += 1 }
        if !goals.isEmpty { completedFields += 1 }
        if !topics.isEmpty { completedFields += 1 }
        if completedAt != nil { completedFields += 1 }
        
        return completedFields / totalFields
    }
    
    /// Get validation errors
    public var validationErrors: [OnboardingValidationError] {
        var errors: [OnboardingValidationError] = []
        
        if referral == nil {
            errors.append(.missingRequiredField("referral"))
        }
        
        if ageRange == nil {
            errors.append(.missingRequiredField("ageRange"))
        }
        
        if gender == nil {
            errors.append(.missingRequiredField("gender"))
        }
        
        if let name = name, name.count > 50 {
            errors.append(.invalidField("name", "Name must be 50 characters or less"))
        }
        
        if goals.count > 5 {
            errors.append(.invalidField("goals", "Maximum 5 goals allowed"))
        }
        
        if topics.count > 5 {
            errors.append(.invalidField("topics", "Maximum 5 topics allowed"))
        }
        
        return errors
    }
    
    /// Check if data is valid
    public var isValid: Bool {
        return validationErrors.isEmpty
    }
    
    /// Get summary of user profile
    public var profileSummary: String {
        var summary = "User Profile:\n"
        
        if let name = name, !name.isEmpty {
            summary += "Name: \(name)\n"
        }
        
        if let age = ageRange {
            summary += "Age: \(age.displayName)\n"
        }
        
        if let gender = gender {
            summary += "Gender: \(gender.displayName)\n"
        }
        
        if let referral = referral {
            summary += "Referral: \(referral.displayName)\n"
        }
        
        if !goals.isEmpty {
            summary += "Goals: \(goals.map { $0.displayName }.joined(separator: ", "))\n"
        }
        
        if !topics.isEmpty {
            summary += "Topics: \(topics.map { $0.displayName }.joined(separator: ", "))\n"
        }
        
        return summary
    }
}

// MARK: - Onboarding Options (Enhanced Domain Enums)
public protocol OnboardingOption: RawRepresentable, CaseIterable, Hashable, Codable where RawValue == String {
    var displayName: String { get }
    var description: String? { get }
    var isPopular: Bool { get }
    var category: OptionCategory { get }
}

public enum OptionCategory: String, CaseIterable, Codable {
    case demographic = "demographic"
    case preference = "preference"
    case goal = "goal"
    case interest = "interest"
    case source = "source"
}

public enum Referral: String, OnboardingOption {
    case appStore = "App Store"
    case instagram = "Instagram"
    case tikTok = "TikTok"
    case friendFamily = "Friend/family"
    case webSearch = "Web search"
    
    public var displayName: String { rawValue }
    
    public var description: String? {
        switch self {
        case .appStore:
            return "Found us on the App Store"
        case .instagram:
            return "Discovered through Instagram"
        case .tikTok:
            return "Found us on TikTok"
        case .friendFamily:
            return "Recommended by someone I know"
        case .webSearch:
            return "Found through web search"
        }
    }
    
    public var isPopular: Bool {
        switch self {
        case .appStore, .friendFamily, .webSearch:
            return true
        default:
            return false
        }
    }
    
    public var category: OptionCategory { .source }
}

public enum AgeRange: String, OnboardingOption {
    case under18 = "13 to 17"
    case from18to24 = "18 to 24"
    case from25to34 = "25 to 34"
    case from35to44 = "35 to 44"
    case from45to54 = "45 to 54"
    case over55 = "55+"
    
    public var displayName: String { rawValue }
    
    public var description: String? {
        switch self {
        case .under18:
            return "Teenage learner"
        case .from18to24:
            return "Young adult"
        case .from25to34:
            return "Early career professional"
        case .from35to44:
            return "Mid-career professional"
        case .from45to54:
            return "Experienced professional"
        case .over55:
            return "Senior learner"
        }
    }
    
    public var isPopular: Bool {
        switch self {
        case .from18to24, .from25to34, .from35to44:
            return true
        default:
            return false
        }
    }
    
    public var category: OptionCategory { .demographic }
}

public enum GenderOptions: String, OnboardingOption {
    case female = "Female"
    case male = "Male"
    case nonBinary = "Non-binary"
    case other = "Other"
    case preferNotToSay = "Prefer not to say"
    
    public var displayName: String { rawValue }
    
    public var description: String? {
        switch self {
        case .female:
            return "Female"
        case .male:
            return "Male"
        case .nonBinary:
            return "Non-binary"
        case .other:
            return "Other gender identity"
        case .preferNotToSay:
            return "Prefer not to specify"
        }
    }
    
    public var isPopular: Bool {
        switch self {
        case .female, .male:
            return true
        default:
            return false
        }
    }
    
    public var category: OptionCategory { .demographic }
}

public enum GoalsOptions: String, OnboardingOption {
    case enjoy = "Enjoy learning new words"
    case enhance = "Enhance my lexicon"
    case travel = "Prepare for travel"
    case other = "Other"
    
    public var displayName: String { rawValue }
    
    public var description: String? {
        switch self {
        case .enjoy:
            return "Learning for personal enjoyment"
        case .enhance:
            return "Expanding vocabulary knowledge"
        case .travel:
            return "Preparing for travel abroad"
        case .other:
            return "Other learning goals"
        }
    }
    
    public var isPopular: Bool {
        switch self {
        case .enjoy, .enhance:
            return true
        default:
            return false
        }
    }
    
    public var category: OptionCategory { .goal }
}

public enum TopicsOptions: String, OnboardingOption {
    case society = "Society"
    case human = "Human body"
    case foreign = "Words in foreign languages"
    case emotions = "Emotions"
    case other = "Other"
    
    public var displayName: String { rawValue }
    
    public var description: String? {
        switch self {
        case .society:
            return "Social and cultural topics"
        case .human:
            return "Human anatomy and health"
        case .foreign:
            return "International languages"
        case .emotions:
            return "Feelings and psychology"
        case .other:
            return "Other topics of interest"
        }
    }
    
    public var isPopular: Bool {
        switch self {
        case .society:
            return true
        default:
            return false
        }
    }
    
    public var category: OptionCategory { .interest }
}

// MARK: - Supporting Types
public struct DeviceInfo: Codable, Equatable, Hashable {
    public let deviceModel: String
    public let systemVersion: String
    public let appVersion: String
    public let locale: String
    public let timeZone: String
    
    public init(
        deviceModel: String = UIDevice.current.model,
        systemVersion: String = UIDevice.current.systemVersion,
        appVersion: String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0",
        locale: String = Locale.current.identifier,
        timeZone: String = TimeZone.current.identifier
    ) {
        self.deviceModel = deviceModel
        self.systemVersion = systemVersion
        self.appVersion = appVersion
        self.locale = locale
        self.timeZone = timeZone
    }
}

public struct UserPreferences: Codable, Equatable, Hashable {
    public var enableNotifications: Bool
    public var enableHapticFeedback: Bool
    public var preferredDifficulty: OnboardingDifficultyLevel
    public var dailyGoal: Int
    public var reminderTime: Date?
    
    public init(
        enableNotifications: Bool = true,
        enableHapticFeedback: Bool = true,
        preferredDifficulty: OnboardingDifficultyLevel = .intermediate,
        dailyGoal: Int = 10,
        reminderTime: Date? = nil
    ) {
        self.enableNotifications = enableNotifications
        self.enableHapticFeedback = enableHapticFeedback
        self.preferredDifficulty = preferredDifficulty
        self.dailyGoal = dailyGoal
        self.reminderTime = reminderTime
    }
}

public enum OnboardingDifficultyLevel: String, CaseIterable, Codable {
    case beginner = "beginner"
    case intermediate = "intermediate"
    case advanced = "advanced"
    
    public var displayName: String {
        switch self {
        case .beginner:
            return "Beginner"
        case .intermediate:
            return "Intermediate"
        case .advanced:
            return "Advanced"
        }
    }
}

public enum OnboardingValidationError: LocalizedError, Equatable, Codable {
    case missingRequiredField(String)
    case invalidField(String, String)
    case dataCorrupted
    case versionMismatch
    
    public var errorDescription: String? {
        switch self {
        case .missingRequiredField(let field):
            return "Required field '\(field)' is missing"
        case .invalidField(let field, let reason):
            return "Field '\(field)' is invalid: \(reason)"
        case .dataCorrupted:
            return "Onboarding data is corrupted"
        case .versionMismatch:
            return "Onboarding data version is incompatible"
        }
    }
}

// MARK: - Convenience Extensions
public extension OnboardingData {
    /// Create a copy with updated timestamp
    func withUpdatedTimestamp() -> OnboardingData {
        var updated = self
        updated.updatedAt = Date()
        return updated
    }
    
    /// Create a completed version
    func completed() -> OnboardingData {
        var completed = self
        completed.completedAt = Date()
        completed.updatedAt = Date()
        return completed
    }
    
    /// Get completion status for each step
    var stepCompletionStatus: [OnboardingStep: Bool] {
        return [
            .referral: referral != nil,
            .age: ageRange != nil,
            .gender: gender != nil,
            .nameInput: name != nil && !name!.isEmpty,
            .goals: !goals.isEmpty,
            .topics: !topics.isEmpty,
            .done: completedAt != nil
        ]
    }
}
