//
//  OnboardingLocalDataSource.swift
//  Vocabulary
//
//  Created by Mohammed Balegh on 06/09/2025.
//

import Foundation
import SwiftData
import Combine
import SwiftUI

/// Enhanced local data source protocol for onboarding data persistence
public protocol OnboardingLocalDataSourceProtocol {
    // MARK: - Core Operations
    func save(_ model: OnboardingDataModel) async throws
    func get() async throws -> OnboardingDataModel?
    func clear() async throws
    func delete() async throws
    
    // MARK: - Advanced Operations
    func update(_ model: OnboardingDataModel) async throws
    func partialUpdate(_ updates: OnboardingDataUpdate) async throws
    func validate(_ model: OnboardingDataModel) async throws -> ValidationResult
    
    // MARK: - Query Operations
    func fetchByVersion(_ version: String) async throws -> [OnboardingDataModel]
    func fetchCompleted() async throws -> [OnboardingDataModel]
    func fetchIncomplete() async throws -> [OnboardingDataModel]
    func fetchByDateRange(_ startDate: Date, _ endDate: Date) async throws -> [OnboardingDataModel]
    func search(_ query: String) async throws -> [OnboardingDataModel]
    
    // MARK: - Statistics
    func getStatistics() async throws -> OnboardingStatistics
    func getCompletionRate() async throws -> Double
    func getAverageCompletionTime() async throws -> TimeInterval
    
    // MARK: - Backup and Restore
    func backup() async throws -> Data
    func restore(from data: Data) async throws
    func export() async throws -> Data
    func `import`(from data: Data) async throws
    
    // MARK: - Configuration
    func updateConfiguration(_ config: OnboardingConfiguration) async throws
    func getConfiguration() async throws -> OnboardingConfiguration
}

/// Advanced local data source implementation with comprehensive functionality
public final class OnboardingLocalDataSource: OnboardingLocalDataSourceProtocol {
    // MARK: - Properties
    private let modelContainer: ModelContainer
    private let modelContext: ModelContext
    private let configuration: OnboardingConfiguration
    private let logger: OnboardingLogger?
    
    // MARK: - Initialization
    public init(
        configuration: OnboardingConfiguration = .default,
        logger: OnboardingLogger? = nil
    ) throws {
        self.configuration = configuration
        self.logger = logger
        
        // Configure SwiftData container with simplified approach
        do {
            // Try with default configuration first
            self.modelContainer = try ModelContainer(for: OnboardingDataModel.self)
            self.modelContext = ModelContext(modelContainer)
        } catch {
            // If that fails, try with explicit configuration
            do {
                let schema = Schema([OnboardingDataModel.self])
                let modelConfiguration = ModelConfiguration(
                    schema: schema,
                    isStoredInMemoryOnly: true,
                    cloudKitDatabase: .none
                )
                
                self.modelContainer = try ModelContainer(
                    for: schema,
                    configurations: [modelConfiguration]
                )
                self.modelContext = ModelContext(modelContainer)
            } catch {
                // If all else fails, throw the original error
                throw error
            }
        }
        
        // Setup logging
        // logger?.logInfo("OnboardingLocalDataSource initialized")
    }
    
    // MARK: - Core Operations
    public func save(_ model: OnboardingDataModel) async throws {
        do {
            // Validate model before saving
            if configuration.enableValidation {
                let validationResult = try await validate(model)
                if !validationResult.isValid {
                    throw OnboardingDataError.validationFailed(validationResult.errors)
                }
            }
            
                // Check if there's an existing model
                let descriptor = FetchDescriptor<OnboardingDataModel>()
            let existing = try modelContext.fetch(descriptor).first
                
                if let existing {
                    // Update existing model
                    existing.update(from: model.toDomain())
                await logger?.logInfo("Updated existing onboarding data model")
                } else {
                    // Insert new model
                modelContext.insert(model)
                await logger?.logInfo("Inserted new onboarding data model")
                }
                
            try modelContext.save()
            await logger?.logInfo("Successfully saved onboarding data")
            } catch {
            await logger?.logError("Failed to save onboarding data: \(error)")
            throw OnboardingDataError.saveFailed(error)
        }
    }
    
    public func get() async throws -> OnboardingDataModel? {
        do {
            let descriptor = FetchDescriptor<OnboardingDataModel>()
            let models = try modelContext.fetch(descriptor)
            let model = models.first
            
            if let model = model {
                await logger?.logInfo("Retrieved onboarding data model")
            } else {
                await logger?.logInfo("No onboarding data found")
            }
            
            return model
        } catch {
            await logger?.logError("Failed to retrieve onboarding data: \(error)")
            throw OnboardingDataError.loadFailed(error)
        }
    }
    
    public func clear() async throws {
        do {
            let descriptor = FetchDescriptor<OnboardingDataModel>()
            let models = try modelContext.fetch(descriptor)
            
            for model in models {
                modelContext.delete(model)
            }
            
            try modelContext.save()
            await logger?.logInfo("Cleared all onboarding data")
        } catch {
            await logger?.logError("Failed to clear onboarding data: \(error)")
            throw OnboardingDataError.deleteFailed(error)
        }
    }
    
    public func delete() async throws {
        try await clear()
    }
    
    // MARK: - Advanced Operations
    public func update(_ model: OnboardingDataModel) async throws {
        try await save(model)
    }
    
    public func partialUpdate(_ updates: OnboardingDataUpdate) async throws {
            do {
                let descriptor = FetchDescriptor<OnboardingDataModel>()
            let models = try modelContext.fetch(descriptor)
            
            guard let existingModel = models.first else {
                throw OnboardingDataError.dataNotFound
            }
            
            existingModel.partialUpdate(updates)
            try modelContext.save()
            
            await logger?.logInfo("Partially updated onboarding data")
        } catch {
            await logger?.logError("Failed to partially update onboarding data: \(error)")
            throw OnboardingDataError.saveFailed(error)
        }
    }
    
    public func validate(_ model: OnboardingDataModel) async throws -> ValidationResult {
        let errors = model.validationErrors
        let isValid = errors.isEmpty
        let score = model.completionPercentage
        
        let validationErrors = errors.map { OnboardingValidationError.invalidField("model", $0) }
        
        return ValidationResult(
            isValid: isValid,
            errors: validationErrors,
            warnings: generateWarnings(for: model),
            score: score
        )
    }
    
    // MARK: - Query Operations
    public func fetchByVersion(_ version: String) async throws -> [OnboardingDataModel] {
        do {
            let descriptor = FetchDescriptor<OnboardingDataModel>(
                predicate: #Predicate { $0.version == version }
            )
            let models = try modelContext.fetch(descriptor)
            await logger?.logInfo("Fetched \(models.count) models for version \(version)")
            return models
        } catch {
            await logger?.logError("Failed to fetch models by version: \(error)")
            throw OnboardingDataError.loadFailed(error)
        }
    }
    
    public func fetchCompleted() async throws -> [OnboardingDataModel] {
        do {
            let descriptor = FetchDescriptor<OnboardingDataModel>(
                predicate: #Predicate { $0.completedAt != nil }
            )
            let models = try modelContext.fetch(descriptor)
            await logger?.logInfo("Fetched \(models.count) completed models")
            return models
        } catch {
            await logger?.logError("Failed to fetch completed models: \(error)")
            throw OnboardingDataError.loadFailed(error)
        }
    }
    
    public func fetchIncomplete() async throws -> [OnboardingDataModel] {
        do {
            let descriptor = FetchDescriptor<OnboardingDataModel>(
                predicate: #Predicate { $0.completedAt == nil }
            )
            let models = try modelContext.fetch(descriptor)
            await logger?.logInfo("Fetched \(models.count) incomplete models")
            return models
        } catch {
            await logger?.logError("Failed to fetch incomplete models: \(error)")
            throw OnboardingDataError.loadFailed(error)
        }
    }
    
    public func fetchByDateRange(_ startDate: Date, _ endDate: Date) async throws -> [OnboardingDataModel] {
        do {
            let descriptor = FetchDescriptor<OnboardingDataModel>(
                predicate: #Predicate { model in
                    model.createdAt >= startDate && model.createdAt <= endDate
                }
            )
            let models = try modelContext.fetch(descriptor)
            await logger?.logInfo("Fetched \(models.count) models for date range")
            return models
        } catch {
            await logger?.logError("Failed to fetch models by date range: \(error)")
            throw OnboardingDataError.loadFailed(error)
        }
    }
    
    public func search(_ query: String) async throws -> [OnboardingDataModel] {
        do {
            let descriptor = FetchDescriptor<OnboardingDataModel>()
            let allModels = try modelContext.fetch(descriptor)
            
            let lowercaseQuery = query.lowercased()
            let filteredModels = allModels.filter { model in
                model.name?.lowercased().contains(lowercaseQuery) == true ||
                model.referral?.displayName.lowercased().contains(lowercaseQuery) == true ||
                model.ageRange?.displayName.lowercased().contains(lowercaseQuery) == true ||
                model.gender?.displayName.lowercased().contains(lowercaseQuery) == true ||
                model.goals.contains { $0.displayName.lowercased().contains(lowercaseQuery) } ||
                model.topics.contains { $0.displayName.lowercased().contains(lowercaseQuery) }
            }
            
            await logger?.logInfo("Found \(filteredModels.count) models matching query: \(query)")
            return filteredModels
        } catch {
            await logger?.logError("Failed to search models: \(error)")
            throw OnboardingDataError.loadFailed(error)
        }
    }
    
    // MARK: - Statistics
    public func getStatistics() async throws -> OnboardingStatistics {
            do {
                let descriptor = FetchDescriptor<OnboardingDataModel>()
            let models = try modelContext.fetch(descriptor)
            
            let totalSteps = OnboardingStep.allCases.count
            let completedSteps = models.first?.stepCompletionStatus.values.filter { $0 }.count ?? 0
            let skippedSteps = models.first?.stepCompletionStatus.values.filter { !$0 }.count ?? 0
            let totalTimeSpent = models.first?.totalTimeSpent ?? 0.0
            
            let statistics = OnboardingStatistics(
                totalSteps: totalSteps,
                completedSteps: completedSteps,
                skippedSteps: skippedSteps,
                totalTimeSpent: totalTimeSpent
            )
            
            await logger?.logInfo("Generated statistics: \(statistics)")
            return statistics
        } catch {
            await logger?.logError("Failed to generate statistics: \(error)")
            throw OnboardingDataError.loadFailed(error)
        }
    }
    
    public func getCompletionRate() async throws -> Double {
        let statistics = try await getStatistics()
        return statistics.completionRate
    }
    
    public func getAverageCompletionTime() async throws -> TimeInterval {
        let statistics = try await getStatistics()
        return statistics.averageTimePerStep
    }
    
    // MARK: - Backup and Restore
    public func backup() async throws -> Data {
        // Note: JSON encoding not available for SwiftData models
        // This would require a separate data transfer object
        throw OnboardingDataError.exportFailed(NSError(domain: "OnboardingDataError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Backup not supported for SwiftData models"]))
    }
    
    public func restore(from data: Data) async throws {
        // Note: JSON decoding not available for SwiftData models
        // This would require a separate data transfer object
        throw OnboardingDataError.importFailed(NSError(domain: "OnboardingDataError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Restore not supported for SwiftData models"]))
    }
    
    public func export() async throws -> Data {
        return try await backup()
    }
    
    public func `import`(from data: Data) async throws {
        try await restore(from: data)
    }
    
    // MARK: - Configuration
    public func updateConfiguration(_ config: OnboardingConfiguration) async throws {
        // Configuration is immutable in this implementation
        // In a real app, you might store this in UserDefaults or a separate model
        await logger?.logInfo("Configuration update requested")
    }
    
    public func getConfiguration() async throws -> OnboardingConfiguration {
        return configuration
    }
    
    // MARK: - Private Methods
    private func generateWarnings(for model: OnboardingDataModel) -> [String] {
        var warnings: [String] = []
        
        if model.name?.isEmpty == true {
            warnings.append("Name is empty")
        }
        
        if model.goals.isEmpty {
            warnings.append("No goals selected")
        }
        
        if model.topics.isEmpty {
            warnings.append("No topics selected")
        }
        
        if model.totalTimeSpent == 0 {
            warnings.append("No time spent recorded")
        }
        
        return warnings
    }
}

// MARK: - Logger Protocol
public protocol OnboardingLogger {
    func logInfo(_ message: String) async
    func logWarning(_ message: String) async
    func logError(_ message: String) async
}

// MARK: - Default Logger Implementation
public final class DefaultOnboardingLogger: OnboardingLogger {
    private let enableLogging: Bool
    
    public init(enableLogging: Bool = true) {
        self.enableLogging = enableLogging
    }
    
    public func logInfo(_ message: String) async {
        guard enableLogging else { return }
        print("[OnboardingDataSource] INFO: \(message)")
    }
    
    public func logWarning(_ message: String) async {
        guard enableLogging else { return }
        print("[OnboardingDataSource] WARNING: \(message)")
    }
    
    public func logError(_ message: String) async {
        guard enableLogging else { return }
        print("[OnboardingDataSource] ERROR: \(message)")
    }
}

// MARK: - Legacy Compatibility
// Note: OnboardingLocalDataSource is already the class name, no typealias needed
