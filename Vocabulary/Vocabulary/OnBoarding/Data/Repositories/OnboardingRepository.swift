//
//  OnboardingRepository.swift
//  Vocabulary
//
//  Created by Mohammed Balegh on 06/09/2025.
//

import Foundation
import Combine
import SwiftUI

/// Advanced onboarding data repository with comprehensive functionality
public final class OnboardingDataRepository: OnboardingDataManager {
    // MARK: - Properties
    private let localDataSource: OnboardingLocalDataSourceProtocol
    private let configuration: OnboardingConfiguration
    private let analyticsService: OnboardingAnalyticsService?
    
    // MARK: - Publishers
    @Published private var currentData: OnboardingData?
    @Published private var currentStatistics: OnboardingStatistics
    @Published private var currentConfiguration: OnboardingConfiguration
    
    public var dataPublisher: AnyPublisher<OnboardingData?, Never> {
        $currentData.eraseToAnyPublisher()
    }
    
    public var statisticsPublisher: AnyPublisher<OnboardingStatistics, Never> {
        $currentStatistics.eraseToAnyPublisher()
    }
    
    public var configurationPublisher: AnyPublisher<OnboardingConfiguration, Never> {
        $currentConfiguration.eraseToAnyPublisher()
    }
    
    // MARK: - Initialization
    public init(
        localDataSource: OnboardingLocalDataSourceProtocol,
        configuration: OnboardingConfiguration = .default,
        analyticsService: OnboardingAnalyticsService? = nil
    ) {
        self.localDataSource = localDataSource
        self.configuration = configuration
        self.analyticsService = analyticsService
        self.currentConfiguration = configuration
        self.currentStatistics = OnboardingStatistics(
            totalSteps: OnboardingStep.allCases.count,
            completedSteps: 0,
            skippedSteps: 0,
            totalTimeSpent: 0
        )
        
        Task {
            await loadInitialData()
        }
    }
    
    // MARK: - Core Data Operations
    public func save(_ data: OnboardingData) async throws {
        do {
            let model = OnboardingDataModel(from: data)
            try await localDataSource.save(model)
            currentData = data
            
            if configuration.enableAnalytics {
                await analyticsService?.trackOnboardingSave(data)
            }
            
            await updateStatistics()
        } catch {
            throw OnboardingDataError.saveFailed(error)
        }
    }
    
    public func fetch() async throws -> OnboardingData? {
        do {
            let model = try await localDataSource.get()
            let data = model?.toDomain()
            currentData = data
            return data
        } catch {
            throw OnboardingDataError.loadFailed(error)
        }
    }
    
    public func clear() async throws {
        do {
            try await localDataSource.clear()
            currentData = nil
            await updateStatistics()
        } catch {
            throw OnboardingDataError.deleteFailed(error)
        }
    }
    
    public func delete() async throws {
        try await clear()
    }
    
    // MARK: - Advanced Data Operations
    public func update(_ data: OnboardingData) async throws {
        try await save(data)
    }
    
    public func partialUpdate(_ updates: OnboardingDataUpdate) async throws {
        guard let currentData = currentData else {
            throw OnboardingDataError.dataNotFound
        }
        
        var updatedData = currentData
        
        if let referral = updates.referral {
            updatedData.referral = referral
        }
        if let ageRange = updates.ageRange {
            updatedData.ageRange = ageRange
        }
        if let gender = updates.gender {
            updatedData.gender = gender
        }
        if let name = updates.name {
            updatedData.name = name
        }
        if let goals = updates.goals {
            updatedData.goals = goals
        }
        if let topics = updates.topics {
            updatedData.topics = topics
        }
        if let completedAt = updates.completedAt {
            updatedData.completedAt = completedAt
        }
        if let userPreferences = updates.userPreferences {
            updatedData.userPreferences = userPreferences
        }
        
        updatedData.updatedAt = Date()
        
        try await save(updatedData)
    }
    
    public func validate(_ data: OnboardingData) async throws -> ValidationResult {
        let errors = data.validationErrors
        let isValid = errors.isEmpty
        let score = data.completionPercentage
        
        return ValidationResult(
            isValid: isValid,
            errors: errors,
            warnings: generateWarnings(for: data),
            score: score
        )
    }
    
    public func export() async throws -> Data {
        guard let data = currentData else {
            throw OnboardingDataError.dataNotFound
        }
        
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = .prettyPrinted
            
            let jsonData = try encoder.encode(data)
            
            if configuration.enableCompression {
                return try compressData(jsonData)
            }
            
            return jsonData
        } catch {
            throw OnboardingDataError.exportFailed(error)
        }
    }
    
    public func `import`(from data: Data) async throws -> OnboardingData {
        do {
            let jsonData: Data
            if configuration.enableCompression {
                jsonData = try decompressData(data)
            } else {
                jsonData = data
            }
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            let importedData = try decoder.decode(OnboardingData.self, from: jsonData)
            
            // Validate imported data
            let validationResult = try await validate(importedData)
            if !validationResult.isValid {
                throw OnboardingDataError.validationFailed(validationResult.errors)
            }
            
            try await save(importedData)
            return importedData
        } catch {
            throw OnboardingDataError.importFailed(error)
        }
    }
    
    // MARK: - Query Operations
    public func fetchByVersion(_ version: String) async throws -> [OnboardingData] {
        // Implementation would depend on data source capabilities
        // For now, return current data if version matches
        guard let data = currentData, data.version == version else {
            return []
        }
        return [data]
    }
    
    public func fetchCompleted() async throws -> [OnboardingData] {
        guard let data = currentData, data.isComplete else {
            return []
        }
        return [data]
    }
    
    public func fetchIncomplete() async throws -> [OnboardingData] {
        guard let data = currentData, !data.isComplete else {
            return []
        }
        return [data]
    }
    
    public func fetchByDateRange(_ startDate: Date, _ endDate: Date) async throws -> [OnboardingData] {
        guard let data = currentData,
              data.createdAt >= startDate && data.createdAt <= endDate else {
            return []
        }
        return [data]
    }
    
    public func search(_ query: String) async throws -> [OnboardingData] {
        guard let data = currentData else {
            return []
        }
        
        let lowercaseQuery = query.lowercased()
        let matches = data.name?.lowercased().contains(lowercaseQuery) == true ||
                     data.referral?.displayName.lowercased().contains(lowercaseQuery) == true ||
                     data.ageRange?.displayName.lowercased().contains(lowercaseQuery) == true ||
                     data.gender?.displayName.lowercased().contains(lowercaseQuery) == true ||
                     data.goals.contains { $0.displayName.lowercased().contains(lowercaseQuery) } ||
                     data.topics.contains { $0.displayName.lowercased().contains(lowercaseQuery) }
        
        return matches ? [data] : []
    }
    
    // MARK: - Statistics and Analytics
    public func getStatistics() async throws -> OnboardingStatistics {
        return currentStatistics
    }
    
    public func getCompletionRate() async throws -> Double {
        return currentStatistics.completionRate
    }
    
    public func getAverageCompletionTime() async throws -> TimeInterval {
        return currentStatistics.averageTimePerStep
    }
    
    public func getPopularOptions() async throws -> PopularOptionsData {
        guard let data = currentData else {
            return PopularOptionsData()
        }
        
        var popularData = PopularOptionsData(totalUsers: 1)
        
        if let referral = data.referral {
            popularData = PopularOptionsData(
                popularReferrals: [referral: 1],
                totalUsers: 1
            )
        }
        
        if let ageRange = data.ageRange {
            popularData = PopularOptionsData(
                popularReferrals: popularData.popularReferrals,
                popularAgeRanges: [ageRange: 1],
                totalUsers: 1
            )
        }
        
        if let gender = data.gender {
            popularData = PopularOptionsData(
                popularReferrals: popularData.popularReferrals,
                popularAgeRanges: popularData.popularAgeRanges,
                popularGenders: [gender: 1],
                totalUsers: 1
            )
        }
        
        if !data.goals.isEmpty {
            let goalsDict = Dictionary(uniqueKeysWithValues: data.goals.map { ($0, 1) })
            popularData = PopularOptionsData(
                popularReferrals: popularData.popularReferrals,
                popularAgeRanges: popularData.popularAgeRanges,
                popularGenders: popularData.popularGenders,
                popularGoals: goalsDict,
                totalUsers: 1
            )
        }
        
        if !data.topics.isEmpty {
            let topicsDict = Dictionary(uniqueKeysWithValues: data.topics.map { ($0, 1) })
            popularData = PopularOptionsData(
                popularReferrals: popularData.popularReferrals,
                popularAgeRanges: popularData.popularAgeRanges,
                popularGenders: popularData.popularGenders,
                popularGoals: popularData.popularGoals,
                popularTopics: topicsDict,
                totalUsers: 1
            )
        }
        
        return popularData
    }
    
    // MARK: - Configuration
    public func updateConfiguration(_ config: OnboardingConfiguration) async throws {
        currentConfiguration = config
    }
    
    public func getConfiguration() async throws -> OnboardingConfiguration {
        return currentConfiguration
    }
    
    // MARK: - Private Methods
    private func loadInitialData() async {
        do {
            currentData = try await fetch()
            await updateStatistics()
        } catch {
            // Handle error silently for initial load
        }
    }
    
    private func updateStatistics() async {
        guard let data = currentData else {
            currentStatistics = OnboardingStatistics(
                totalSteps: OnboardingStep.allCases.count,
                completedSteps: 0,
                skippedSteps: 0,
                totalTimeSpent: 0
            )
            return
        }
        
        let completedSteps = data.stepCompletionStatus.values.filter { $0 }.count
        let skippedSteps = data.stepCompletionStatus.values.filter { !$0 }.count
        let totalTimeSpent = data.updatedAt.timeIntervalSince(data.createdAt)
        
        currentStatistics = OnboardingStatistics(
            totalSteps: OnboardingStep.allCases.count,
            completedSteps: completedSteps,
            skippedSteps: skippedSteps,
            totalTimeSpent: totalTimeSpent
        )
    }
    
    private func generateWarnings(for data: OnboardingData) -> [String] {
        var warnings: [String] = []
        
        if data.name?.isEmpty == true {
            warnings.append("Name is empty")
        }
        
        if data.goals.isEmpty {
            warnings.append("No goals selected")
        }
        
        if data.topics.isEmpty {
            warnings.append("No topics selected")
        }
        
        return warnings
    }
    
    private func compressData(_ data: Data) throws -> Data {
        // Simple compression implementation
        // In a real app, you might use Compression framework
        return data
    }
    
    private func decompressData(_ data: Data) throws -> Data {
        // Simple decompression implementation
        // In a real app, you might use Compression framework
        return data
    }
}

// MARK: - Analytics Service Protocol
public protocol OnboardingAnalyticsService {
    func trackOnboardingSave(_ data: OnboardingData) async
    func trackOnboardingCompletion(_ data: OnboardingData) async
    func trackOnboardingStep(_ step: OnboardingStep, timeSpent: TimeInterval) async
}

// MARK: - Legacy Compatibility
public typealias OnboardingRepository = OnboardingDataRepository

