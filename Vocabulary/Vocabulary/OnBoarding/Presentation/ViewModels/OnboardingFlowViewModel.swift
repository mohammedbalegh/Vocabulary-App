//
//  OnboardingFlowViewModel.swift
//  Vocabulary
//
//  Created by Mohammed Balegh on 06/09/2025.
//

import Foundation
import Combine
import SwiftUI

/// Advanced onboarding flow view model with comprehensive state management
@MainActor
public final class OnboardingFlowViewModel: ObservableObject {
    
    // MARK: - Published State
    @Published public private(set) var activeStep: OnboardingStep = .referral
    @Published public private(set) var userProfile: UserProfile = UserProfile()
    @Published public private(set) var flowState: OnboardingFlowState = .active
    @Published public private(set) var errorState: OnboardingErrorState = .none
    @Published public private(set) var progressPercentage: Double = 0.0
    @Published public private(set) var timeSpent: TimeInterval = 0.0
    @Published public private(set) var stepStartTime: Date = Date()
    @Published public private(set) var isAnimating: Bool = false
    @Published public private(set) var canGoBack: Bool = false
    @Published public private(set) var canSkip: Bool = false
    
    // MARK: - Dependencies
    private let dataPersistenceService: SaveOnboardingDataUseCaseProtocol
    private let dataRetrievalService: OnboardingDataManager
    private let configuration: OnboardingFlowConfiguration
    private let analyticsService: OnboardingAnalyticsService?
    private let hapticManager: TactileFeedbackProvider
    private let completionHandler: () -> Void
    
    // MARK: - Internal State
    private var subscriptionBag = Set<AnyCancellable>()
    private var stepHistory: [OnboardingStep] = []
    private var stepTimes: [OnboardingStep: TimeInterval] = [:]
    private var flowStartTime: Date = Date()
    private var currentStepStartTime: Date = Date()
    
    // MARK: - Initialization
    public init(
        saveDataUseCase: SaveOnboardingDataUseCaseProtocol,
        repository: OnboardingDataManager,
        configuration: OnboardingFlowConfiguration = .default,
        analyticsService: OnboardingAnalyticsService? = nil,
        hapticManager: TactileFeedbackProvider = AdvancedHapticManager.shared,
        onboardingCompleted: @escaping () -> Void
    ) {
        self.dataPersistenceService = saveDataUseCase
        self.dataRetrievalService = repository
        self.configuration = configuration
        self.analyticsService = analyticsService
        self.hapticManager = hapticManager
        self.completionHandler = onboardingCompleted
        
        initializeFlow()
    }
    
    // MARK: - Public Interface
    public func advanceToNextStep() {
        guard let nextStep = activeStep.next else {
            if activeStep == .done {
                finalizeOnboardingProcess()
            }
            return
        }
        
        recordStepCompletion()
        persistCurrentStepData()
        navigateToStep(nextStep)
    }
    
    public func navigateToPreviousStep() {
        guard let previousStep = activeStep.previous else { return }
        recordStepCompletion()
        navigateToStep(previousStep)
    }
    
    public func skipCurrentStep() {
        guard activeStep.allowsSkip else { return }
        recordStepCompletion()
        advanceToNextStep()
    }
    
    public func updateUserReferral(_ referral: Referral?) {
        userProfile.referral = referral
        updateProgress()
    }
    
    public func updateUserAge(_ age: AgeRange?) {
        userProfile.ageRange = age
        updateProgress()
    }
    
    public func updateUserGender(_ gender: GenderOptions?) {
        userProfile.gender = gender
        updateProgress()
    }
    
    public func updateUserName(_ name: String) {
        userProfile.name = name.isEmpty ? nil : name
        updateProgress()
    }
    
    public func updateUserGoals(_ goals: Set<GoalsOptions>) {
        userProfile.goals = goals
        updateProgress()
    }
    
    public func updateUserTopics(_ topics: Set<TopicsOptions>) {
        userProfile.topics = topics
        updateProgress()
    }
    
    public func resetOnboardingFlow() {
        Task {
            do {
                try await dataRetrievalService.clear()
                userProfile = UserProfile()
                activeStep = .referral
                stepHistory.removeAll()
                stepTimes.removeAll()
                flowStartTime = Date()
                currentStepStartTime = Date()
                updateProgress()
                updateNavigationState()
                
                if configuration.enableHapticFeedback {
                    hapticManager.provideSuccessFeedback()
                }
            } catch {
                errorState = .dataOperationFailed(error.localizedDescription)
            }
        }
    }
    
    public func clearError() {
        errorState = .none
    }
    
    public func startAnimation() {
        isAnimating = true
    }
    
    public func stopAnimation() {
        isAnimating = false
    }
    
    // MARK: - Private Implementation
    private func initializeFlow() {
        loadPersistedUserData()
        updateNavigationState()
        updateProgress()
    }
    
    private func loadPersistedUserData() {
        Task {
            do {
                let persistedData = try await dataRetrievalService.fetch()
                if let data = persistedData, !data.isComplete {
                    userProfile = UserProfile(from: data)
                    determineResumeStep(from: data)
                    updateProgress()
                    updateNavigationState()
                }
            } catch {
                errorState = .dataLoadFailed(error.localizedDescription)
            }
        }
    }
    
    private func persistCurrentStepData() {
        Task {
            do {
                let dataToSave = OnboardingData(from: userProfile)
                try await dataRetrievalService.save(dataToSave)
                
                if configuration.enableAnalytics {
                    await analyticsService?.trackOnboardingSave(dataToSave)
                }
            } catch {
                errorState = .dataSaveFailed(error.localizedDescription)
            }
        }
    }
    
    private func finalizeOnboardingProcess() {
        userProfile.completedAt = Date()
        let finalData = OnboardingData(from: userProfile)
        
        Task {
            do {
                try await dataRetrievalService.save(finalData)
                
                // Mark onboarding as completed in UserDefaults
                UserDefaults.standard.set(true, forKey: "onboardingCompleted")
                
                if configuration.enableAnalytics {
                    await analyticsService?.trackOnboardingCompletion(finalData)
                }
                
                if configuration.enableHapticFeedback {
                    hapticManager.provideSuccessFeedback()
                }
                
                flowState = .completed
                completionHandler()
            } catch {
                errorState = .dataSaveFailed(error.localizedDescription)
            }
        }
    }
    
    private func navigateToStep(_ step: OnboardingStep) {
        stepHistory.append(activeStep)
        currentStepStartTime = Date()
        
        if configuration.enableAnimations {
            withAnimation(.easeInOut(duration: 0.3)) {
                activeStep = step
            }
        } else {
            activeStep = step
        }
        
        updateNavigationState()
        updateProgress()
        
        if configuration.enableHapticFeedback {
            hapticManager.provideLightImpact()
        }
    }
    
    private func determineResumeStep(from data: OnboardingData) {
        if data.referral == nil {
            activeStep = .referral
        } else if data.ageRange == nil {
            activeStep = .tailor
        } else if data.gender == nil {
            activeStep = .age
        } else if data.name == nil {
            activeStep = .gender
        } else if data.goals.isEmpty {
            activeStep = .nameInput
        } else if data.topics.isEmpty {
            activeStep = .goals
        } else {
            activeStep = .topics
        }
    }
    
    private func recordStepCompletion() {
        let timeSpent = Date().timeIntervalSince(currentStepStartTime)
        stepTimes[activeStep] = timeSpent
        self.timeSpent += timeSpent
        
        if configuration.enableAnalytics {
            Task {
                await analyticsService?.trackOnboardingStep(activeStep, timeSpent: timeSpent)
            }
        }
    }
    
    private func updateProgress() {
        let totalSteps = OnboardingStep.allCases.count
        let completedSteps = userProfile.completionPercentage * Double(totalSteps)
        progressPercentage = completedSteps / Double(totalSteps)
    }
    
    private func updateNavigationState() {
        canGoBack = configuration.allowBackNavigation && !stepHistory.isEmpty
        canSkip = activeStep.allowsSkip
    }
}

// MARK: - Supporting Types
public enum OnboardingFlowState: Equatable {
    case active
    case completed
    case error
    case paused
}

public enum OnboardingErrorState: Equatable {
    case none
    case dataLoadFailed(String)
    case dataSaveFailed(String)
    case dataOperationFailed(String)
    case validationFailed([OnboardingValidationError])
    case networkError(String)
    
    public var error: Error? {
        switch self {
        case .none:
            return nil
        case .dataLoadFailed(let message), .dataSaveFailed(let message), .dataOperationFailed(let message), .networkError(let message):
            return NSError(domain: "OnboardingError", code: 0, userInfo: [NSLocalizedDescriptionKey: message])
        case .validationFailed(let errors):
            return OnboardingDataError.validationFailed(errors)
        }
    }
}

// MARK: - User Profile Model
public struct UserProfile: Equatable {
    public var referral: Referral?
    public var ageRange: AgeRange?
    public var gender: GenderOptions?
    public var name: String?
    public var goals: Set<GoalsOptions>
    public var topics: Set<TopicsOptions>
    public var completedAt: Date?
    public var preferences: UserPreferences
    
    public init() {
        self.goals = []
        self.topics = []
        self.preferences = UserPreferences()
    }
    
    public init(from data: OnboardingData) {
        self.referral = data.referral
        self.ageRange = data.ageRange
        self.gender = data.gender
        self.name = data.name
        self.goals = data.goals
        self.topics = data.topics
        self.completedAt = data.completedAt
        self.preferences = data.userPreferences
    }
    
    public var isComplete: Bool {
        completedAt != nil
    }
    
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
}

// MARK: - OnboardingData Extension
public extension OnboardingData {
    init(from profile: UserProfile) {
        self.init(
            referral: profile.referral,
            ageRange: profile.ageRange,
            gender: profile.gender,
            name: profile.name,
            goals: profile.goals,
            topics: profile.topics,
            completedAt: profile.completedAt,
            userPreferences: profile.preferences
        )
    }
}

// MARK: - Legacy Compatibility
public extension OnboardingFlowViewModel {
    var currentStep: OnboardingStep { activeStep }
    var onboardingData: OnboardingData { OnboardingData(from: userProfile) }
    var error: Error? { errorState.error }
    var showOnboarding: Bool { flowState == .active }
    
    func proceedToNext() { advanceToNextStep() }
    func goBack() { navigateToPreviousStep() }
    func skip() { skipCurrentStep() }
    func updateReferral(_ referral: Referral?) { updateUserReferral(referral) }
    func updateAge(_ age: AgeRange?) { updateUserAge(age) }
    func updateGender(_ gender: GenderOptions?) { updateUserGender(gender) }
    func updateName(_ name: String) { updateUserName(name) }
    func updateGoals(_ goals: Set<GoalsOptions>) { updateUserGoals(goals) }
    func updateTopics(_ topics: Set<TopicsOptions>) { updateUserTopics(topics) }
    func restart() { resetOnboardingFlow() }
}
