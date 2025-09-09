//
//  OnboardingRepositoryProtocol.swift
//  Vocabulary
//
//  Created by Mohammed Balegh on 06/09/2025.
//

import Foundation
import Combine

/// Comprehensive data management protocol for onboarding operations
public protocol OnboardingDataManager {
    // MARK: - Core Data Operations
    func save(_ data: OnboardingData) async throws
    func fetch() async throws -> OnboardingData?
    func clear() async throws
    func delete() async throws
    
    // MARK: - Advanced Data Operations
    func update(_ data: OnboardingData) async throws
    func partialUpdate(_ updates: OnboardingDataUpdate) async throws
    func validate(_ data: OnboardingData) async throws -> ValidationResult
    func export() async throws -> Data
    func `import`(from data: Data) async throws -> OnboardingData
    
    // MARK: - Query Operations
    func fetchByVersion(_ version: String) async throws -> [OnboardingData]
    func fetchCompleted() async throws -> [OnboardingData]
    func fetchIncomplete() async throws -> [OnboardingData]
    func fetchByDateRange(_ startDate: Date, _ endDate: Date) async throws -> [OnboardingData]
    func search(_ query: String) async throws -> [OnboardingData]
    
    // MARK: - Statistics and Analytics
    func getStatistics() async throws -> OnboardingStatistics
    func getCompletionRate() async throws -> Double
    func getAverageCompletionTime() async throws -> TimeInterval
    func getPopularOptions() async throws -> PopularOptionsData
    
    // MARK: - Configuration
    func updateConfiguration(_ config: OnboardingConfiguration) async throws
    func getConfiguration() async throws -> OnboardingConfiguration
    
    // MARK: - Reactive Updates
    var dataPublisher: AnyPublisher<OnboardingData?, Never> { get }
    var statisticsPublisher: AnyPublisher<OnboardingStatistics, Never> { get }
    var configurationPublisher: AnyPublisher<OnboardingConfiguration, Never> { get }
}

/// Configuration for onboarding data management
public struct OnboardingConfiguration: Codable, Equatable {
    public let enableAnalytics: Bool
    public let enableBackup: Bool
    public let maxDataRetentionDays: Int
    public let enableValidation: Bool
    public let enableCompression: Bool
    public let encryptionEnabled: Bool
    public let syncInterval: TimeInterval
    public let maxRetryAttempts: Int
    
    public init(
        enableAnalytics: Bool = true,
        enableBackup: Bool = true,
        maxDataRetentionDays: Int = 365,
        enableValidation: Bool = true,
        enableCompression: Bool = true,
        encryptionEnabled: Bool = false,
        syncInterval: TimeInterval = 300.0,
        maxRetryAttempts: Int = 3
    ) {
        self.enableAnalytics = enableAnalytics
        self.enableBackup = enableBackup
        self.maxDataRetentionDays = maxDataRetentionDays
        self.enableValidation = enableValidation
        self.enableCompression = enableCompression
        self.encryptionEnabled = encryptionEnabled
        self.syncInterval = syncInterval
        self.maxRetryAttempts = maxRetryAttempts
    }
    
    public static let `default` = OnboardingConfiguration()
}

/// Partial update structure for onboarding data
public struct OnboardingDataUpdate: Codable, Equatable {
    public let id: UUID
    public var referral: Referral?
    public var ageRange: AgeRange?
    public var gender: GenderOptions?
    public var name: String?
    public var goals: Set<GoalsOptions>?
    public var topics: Set<TopicsOptions>?
    public var completedAt: Date?
    public var userPreferences: UserPreferences?
    
    public init(
        id: UUID,
        referral: Referral? = nil,
        ageRange: AgeRange? = nil,
        gender: GenderOptions? = nil,
        name: String? = nil,
        goals: Set<GoalsOptions>? = nil,
        topics: Set<TopicsOptions>? = nil,
        completedAt: Date? = nil,
        userPreferences: UserPreferences? = nil
    ) {
        self.id = id
        self.referral = referral
        self.ageRange = ageRange
        self.gender = gender
        self.name = name
        self.goals = goals
        self.topics = topics
        self.completedAt = completedAt
        self.userPreferences = userPreferences
    }
}

/// Validation result for onboarding data
public struct ValidationResult: Codable, Equatable {
    public let isValid: Bool
    public let errors: [OnboardingValidationError]
    public let warnings: [String]
    public let score: Double
    
    public init(
        isValid: Bool,
        errors: [OnboardingValidationError] = [],
        warnings: [String] = [],
        score: Double = 0.0
    ) {
        self.isValid = isValid
        self.errors = errors
        self.warnings = warnings
        self.score = score
    }
    
    public static let valid = ValidationResult(isValid: true, score: 1.0)
    public static let invalid = ValidationResult(isValid: false, score: 0.0)
}

/// Popular options data for analytics
public struct PopularOptionsData: Codable, Equatable {
    public let popularReferrals: [Referral: Int]
    public let popularAgeRanges: [AgeRange: Int]
    public let popularGenders: [GenderOptions: Int]
    public let popularGoals: [GoalsOptions: Int]
    public let popularTopics: [TopicsOptions: Int]
    public let totalUsers: Int
    
    public init(
        popularReferrals: [Referral: Int] = [:],
        popularAgeRanges: [AgeRange: Int] = [:],
        popularGenders: [GenderOptions: Int] = [:],
        popularGoals: [GoalsOptions: Int] = [:],
        popularTopics: [TopicsOptions: Int] = [:],
        totalUsers: Int = 0
    ) {
        self.popularReferrals = popularReferrals
        self.popularAgeRanges = popularAgeRanges
        self.popularGenders = popularGenders
        self.popularGoals = popularGoals
        self.popularTopics = popularTopics
        self.totalUsers = totalUsers
    }
}

/// Error types for onboarding data management
public enum OnboardingDataError: LocalizedError {
    case dataNotFound
    case validationFailed([OnboardingValidationError])
    case saveFailed(Error)
    case loadFailed(Error)
    case deleteFailed(Error)
    case exportFailed(Error)
    case importFailed(Error)
    case configurationError(String)
    case networkError(Error)
    case storageError(Error)
    case encryptionError(Error)
    case compressionError(Error)
    case versionMismatch(String, String)
    case dataCorrupted
    case insufficientPermissions
    case quotaExceeded
    case serviceUnavailable
    
    public var errorDescription: String? {
        switch self {
        case .dataNotFound:
            return "Onboarding data not found"
        case .validationFailed(let errors):
            return "Validation failed: \(errors.map { $0.localizedDescription }.joined(separator: ", "))"
        case .saveFailed(let error):
            return "Failed to save data: \(error.localizedDescription)"
        case .loadFailed(let error):
            return "Failed to load data: \(error.localizedDescription)"
        case .deleteFailed(let error):
            return "Failed to delete data: \(error.localizedDescription)"
        case .exportFailed(let error):
            return "Failed to export data: \(error.localizedDescription)"
        case .importFailed(let error):
            return "Failed to import data: \(error.localizedDescription)"
        case .configurationError(let message):
            return "Configuration error: \(message)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .storageError(let error):
            return "Storage error: \(error.localizedDescription)"
        case .encryptionError(let error):
            return "Encryption error: \(error.localizedDescription)"
        case .compressionError(let error):
            return "Compression error: \(error.localizedDescription)"
        case .versionMismatch(let current, let expected):
            return "Version mismatch: current \(current), expected \(expected)"
        case .dataCorrupted:
            return "Data is corrupted"
        case .insufficientPermissions:
            return "Insufficient permissions"
        case .quotaExceeded:
            return "Storage quota exceeded"
        case .serviceUnavailable:
            return "Service temporarily unavailable"
        }
    }
}

// MARK: - Legacy Compatibility
public typealias OnboardingRepositoryProtocol = OnboardingDataManager
