//
//  OnboardingDataModel.swift
//  Vocabulary
//
//  Created by Mohammed Balegh on 06/09/2025.
//

import Foundation
import SwiftData
import SwiftUI

/// Enhanced SwiftData model for onboarding data persistence
@Model
public final class OnboardingDataModel {
    // MARK: - Core Properties
    public var id: UUID
    public var version: String
    public var createdAt: Date
    public var updatedAt: Date
    
    // MARK: - User Data Properties
    public var referralRaw: String?
    public var ageRangeRaw: String?
    public var genderRaw: String?
    public var name: String?
    public var goalsRaw: [String]
    public var topicsRaw: [String]
    public var completedAt: Date?
    
    // MARK: - Device and Preferences
    public var deviceModel: String?
    public var systemVersion: String?
    public var appVersion: String?
    public var locale: String?
    public var timeZone: String?
    
    // MARK: - User Preferences
    public var enableNotifications: Bool
    public var enableHapticFeedback: Bool
    public var preferredDifficultyRaw: String?
    public var dailyGoal: Int
    public var reminderTime: Date?
    
    // MARK: - Analytics
    public var stepCompletionTimes: [String: Double] // step name -> time spent
    public var totalTimeSpent: Double
    public var completionRate: Double
    public var lastAccessedAt: Date?
    
    // MARK: - Initialization
    public init(
        id: UUID = UUID(),
        version: String = "1.0",
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        referralRaw: String? = nil,
        ageRangeRaw: String? = nil,
        genderRaw: String? = nil,
        name: String? = nil,
        goalsRaw: [String] = [],
        topicsRaw: [String] = [],
        completedAt: Date? = nil,
        deviceModel: String? = nil,
        systemVersion: String? = nil,
        appVersion: String? = nil,
        locale: String? = nil,
        timeZone: String? = nil,
        enableNotifications: Bool = true,
        enableHapticFeedback: Bool = true,
        preferredDifficultyRaw: String? = nil,
        dailyGoal: Int = 10,
        reminderTime: Date? = nil,
        stepCompletionTimes: [String: Double] = [:],
        totalTimeSpent: Double = 0.0,
        completionRate: Double = 0.0,
        lastAccessedAt: Date? = nil
    ) {
        self.id = id
        self.version = version
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.referralRaw = referralRaw
        self.ageRangeRaw = ageRangeRaw
        self.genderRaw = genderRaw
        self.name = name
        self.goalsRaw = goalsRaw
        self.topicsRaw = topicsRaw
        self.completedAt = completedAt
        self.deviceModel = deviceModel
        self.systemVersion = systemVersion
        self.appVersion = appVersion
        self.locale = locale
        self.timeZone = timeZone
        self.enableNotifications = enableNotifications
        self.enableHapticFeedback = enableHapticFeedback
        self.preferredDifficultyRaw = preferredDifficultyRaw
        self.dailyGoal = dailyGoal
        self.reminderTime = reminderTime
        self.stepCompletionTimes = stepCompletionTimes
        self.totalTimeSpent = totalTimeSpent
        self.completionRate = completionRate
        self.lastAccessedAt = lastAccessedAt
    }
    
    // MARK: - Computed Properties for Domain Mapping
    public var referral: Referral? {
        get { referralRaw.flatMap { Referral(rawValue: $0) } }
        set { 
            referralRaw = newValue?.rawValue
            updatedAt = Date()
        }
    }
    
    public var ageRange: AgeRange? {
        get { ageRangeRaw.flatMap { AgeRange(rawValue: $0) } }
        set { 
            ageRangeRaw = newValue?.rawValue
            updatedAt = Date()
        }
    }
    
    public var gender: GenderOptions? {
        get { genderRaw.flatMap { GenderOptions(rawValue: $0) } }
        set { 
            genderRaw = newValue?.rawValue
            updatedAt = Date()
        }
    }
    
    public var goals: Set<GoalsOptions> {
        get {
            Set(goalsRaw.compactMap { GoalsOptions(rawValue: $0) })
        }
        set {
            goalsRaw = Array(newValue.map { $0.rawValue })
            updatedAt = Date()
        }
    }
    
    public var topics: Set<TopicsOptions> {
        get {
            Set(topicsRaw.compactMap { TopicsOptions(rawValue: $0) })
        }
        set {
            topicsRaw = Array(newValue.map { $0.rawValue })
            updatedAt = Date()
        }
    }
    
    public var preferredDifficulty: OnboardingDifficultyLevel? {
        get { preferredDifficultyRaw.flatMap { OnboardingDifficultyLevel(rawValue: $0) } }
        set { 
            preferredDifficultyRaw = newValue?.rawValue
            updatedAt = Date()
        }
    }
    
    public var deviceInfo: DeviceInfo? {
        get {
            guard let deviceModel = deviceModel,
                  let systemVersion = systemVersion,
                  let appVersion = appVersion,
                  let locale = locale,
                  let timeZone = timeZone else {
                return nil
            }
            return DeviceInfo(
                deviceModel: deviceModel,
                systemVersion: systemVersion,
                appVersion: appVersion,
                locale: locale,
                timeZone: timeZone
            )
        }
        set {
            deviceModel = newValue?.deviceModel
            systemVersion = newValue?.systemVersion
            appVersion = newValue?.appVersion
            locale = newValue?.locale
            timeZone = newValue?.timeZone
            updatedAt = Date()
        }
    }
    
    public var userPreferences: UserPreferences {
        get {
            UserPreferences(
                enableNotifications: enableNotifications,
                enableHapticFeedback: enableHapticFeedback,
                preferredDifficulty: preferredDifficulty ?? .intermediate,
                dailyGoal: dailyGoal,
                reminderTime: reminderTime
            )
        }
        set {
            enableNotifications = newValue.enableNotifications
            enableHapticFeedback = newValue.enableHapticFeedback
            preferredDifficulty = newValue.preferredDifficulty
            dailyGoal = newValue.dailyGoal
            reminderTime = newValue.reminderTime
            updatedAt = Date()
        }
    }
    
    // MARK: - Validation
    public var isValid: Bool {
        return !validationErrors.isEmpty == false
    }
    
    public var validationErrors: [String] {
        var errors: [String] = []
        
        if name?.count ?? 0 > 50 {
            errors.append("Name exceeds maximum length of 50 characters")
        }
        
        if goalsRaw.count > 5 {
            errors.append("Too many goals selected (maximum 5)")
        }
        
        if topicsRaw.count > 5 {
            errors.append("Too many topics selected (maximum 5)")
        }
        
        if dailyGoal < 1 || dailyGoal > 100 {
            errors.append("Daily goal must be between 1 and 100")
        }
        
        if totalTimeSpent < 0 {
            errors.append("Total time spent cannot be negative")
        }
        
        if completionRate < 0 || completionRate > 1 {
            errors.append("Completion rate must be between 0 and 1")
        }
        
        return errors
    }
    
    // MARK: - Analytics
    public func recordStepCompletion(_ step: OnboardingStep, timeSpent: TimeInterval) {
        stepCompletionTimes[step.title] = timeSpent
        totalTimeSpent += timeSpent
        lastAccessedAt = Date()
        updatedAt = Date()
        
        // Update completion rate
        let completedSteps = stepCompletionTimes.count
        let totalSteps = OnboardingStep.allCases.count
        completionRate = Double(completedSteps) / Double(totalSteps)
    }
    
    public func getStepTimeSpent(_ step: OnboardingStep) -> TimeInterval {
        return stepCompletionTimes[step.title] ?? 0.0
    }
    
    public func getAverageTimePerStep() -> TimeInterval {
        guard !stepCompletionTimes.isEmpty else { return 0.0 }
        return totalTimeSpent / Double(stepCompletionTimes.count)
    }
}

// MARK: - Domain Mapping
public extension OnboardingDataModel {
    convenience init(from domain: OnboardingData) {
        self.init(
            id: domain.id,
            version: domain.version,
            createdAt: domain.createdAt,
            updatedAt: domain.updatedAt,
            referralRaw: domain.referral?.rawValue,
            ageRangeRaw: domain.ageRange?.rawValue,
            genderRaw: domain.gender?.rawValue,
            name: domain.name,
            goalsRaw: Array(domain.goals.map { $0.rawValue }),
            topicsRaw: Array(domain.topics.map { $0.rawValue }),
            completedAt: domain.completedAt,
            deviceModel: domain.deviceInfo?.deviceModel,
            systemVersion: domain.deviceInfo?.systemVersion,
            appVersion: domain.deviceInfo?.appVersion,
            locale: domain.deviceInfo?.locale,
            timeZone: domain.deviceInfo?.timeZone,
            enableNotifications: domain.userPreferences.enableNotifications,
            enableHapticFeedback: domain.userPreferences.enableHapticFeedback,
            preferredDifficultyRaw: domain.userPreferences.preferredDifficulty.rawValue,
            dailyGoal: domain.userPreferences.dailyGoal,
            reminderTime: domain.userPreferences.reminderTime
        )
    }
    
    func toDomain() -> OnboardingData {
        return OnboardingData(
            id: id,
            referral: referral,
            ageRange: ageRange,
            gender: gender,
            name: name,
            goals: goals,
            topics: topics,
            completedAt: completedAt,
            createdAt: createdAt,
            updatedAt: updatedAt,
            version: version,
            deviceInfo: deviceInfo,
            userPreferences: userPreferences
        )
    }
    
    func update(from domain: OnboardingData) {
        self.referral = domain.referral
        self.ageRange = domain.ageRange
        self.gender = domain.gender
        self.name = domain.name
        self.goals = domain.goals
        self.topics = domain.topics
        self.completedAt = domain.completedAt
        self.deviceInfo = domain.deviceInfo
        self.userPreferences = domain.userPreferences
        self.version = domain.version
        self.updatedAt = Date()
        self.lastAccessedAt = Date()
    }
    
    func partialUpdate(_ updates: OnboardingDataUpdate) {
        if let referral = updates.referral {
            self.referral = referral
        }
        if let ageRange = updates.ageRange {
            self.ageRange = ageRange
        }
        if let gender = updates.gender {
            self.gender = gender
        }
        if let name = updates.name {
            self.name = name
        }
        if let goals = updates.goals {
            self.goals = goals
        }
        if let topics = updates.topics {
            self.topics = topics
        }
        if let completedAt = updates.completedAt {
            self.completedAt = completedAt
        }
        if let userPreferences = updates.userPreferences {
            self.userPreferences = userPreferences
        }
        
        self.updatedAt = Date()
        self.lastAccessedAt = Date()
    }
}

// MARK: - Convenience Extensions
public extension OnboardingDataModel {
    /// Check if onboarding is complete
    var isComplete: Bool {
        return completedAt != nil
    }
    
    /// Get completion percentage
    var completionPercentage: Double {
        return completionRate
    }
    
    /// Get profile summary
    var profileSummary: String {
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
        
        summary += "Completion Rate: \(Int(completionRate * 100))%\n"
        summary += "Total Time Spent: \(Int(totalTimeSpent)) seconds"
        
        return summary
    }
    
    /// Get step completion status
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
