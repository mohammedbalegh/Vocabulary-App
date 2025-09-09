//
//  VocabularyRepositoryProtocol.swift
//  Vocabulary
//
//  Created by Mohammed Balegh on 08/09/2025.
//

import Foundation
import Combine

/// Comprehensive protocol for vocabulary data management
/// Defines all operations needed for vocabulary learning and progress tracking
public protocol VocabularyDataManager {
    
    // MARK: - Core Data Operations
    func fetchAllVocabulary() async throws -> [VocabularyWord]
    func fetchVocabulary(by id: UUID) async throws -> VocabularyWord?
    func fetchVocabulary(by word: String) async throws -> VocabularyWord?
    func fetchVocabulary(by category: WordCategory) async throws -> [VocabularyWord]
    func fetchVocabulary(by difficulty: DifficultyLevel) async throws -> [VocabularyWord]
    
    // MARK: - Search and Filter Operations
    func searchVocabulary(query: String) async throws -> [VocabularyWord]
    func filterVocabulary(by tags: Set<String>) async throws -> [VocabularyWord]
    func getRandomVocabulary(count: Int) async throws -> [VocabularyWord]
    func getVocabularyByDifficulty(_ difficulty: DifficultyLevel, count: Int) async throws -> [VocabularyWord]
    
    // MARK: - Progress Tracking
    func markAsLearned(_ vocabularyId: UUID) async throws
    func markAsUnlearned(_ vocabularyId: UUID) async throws
    func getLearnedVocabulary() async throws -> Set<UUID>
    func getLearningProgress() async throws -> LearningProgress
    
    // MARK: - Statistics and Analytics
    func getVocabularyStatistics() async throws -> VocabularyStatistics
    func getCategoryStatistics() async throws -> [WordCategory: Int]
    func getDifficultyStatistics() async throws -> [DifficultyLevel: Int]
    
    // MARK: - Data Management
    func addVocabulary(_ vocabulary: VocabularyWord) async throws
    func updateVocabulary(_ vocabulary: VocabularyWord) async throws
    func deleteVocabulary(_ id: UUID) async throws
    func clearAllData() async throws
    
    // MARK: - Reactive Updates
    var vocabularyPublisher: AnyPublisher<[VocabularyWord], Never> { get }
    var progressPublisher: AnyPublisher<LearningProgress, Never> { get }
}

// MARK: - Supporting Types
public struct LearningProgress {
    public let totalWords: Int
    public let learnedWords: Int
    public let learningPercentage: Double
    public let currentStreak: Int
    public let lastLearningDate: Date?
    
    public init(totalWords: Int, learnedWords: Int, currentStreak: Int = 0, lastLearningDate: Date? = nil) {
        self.totalWords = totalWords
        self.learnedWords = learnedWords
        self.learningPercentage = totalWords > 0 ? Double(learnedWords) / Double(totalWords) : 0.0
        self.currentStreak = currentStreak
        self.lastLearningDate = lastLearningDate
    }
}

public struct VocabularyStatistics {
    public let totalWords: Int
    public let learnedWords: Int
    public let averageReadingTime: TimeInterval
    public let mostCommonCategory: WordCategory?
    public let mostCommonDifficulty: DifficultyLevel?
    public let learningStreak: Int
    public let lastActivityDate: Date?
    
    public init(
        totalWords: Int,
        learnedWords: Int,
        averageReadingTime: TimeInterval,
        mostCommonCategory: WordCategory? = nil,
        mostCommonDifficulty: DifficultyLevel? = nil,
        learningStreak: Int = 0,
        lastActivityDate: Date? = nil
    ) {
        self.totalWords = totalWords
        self.learnedWords = learnedWords
        self.averageReadingTime = averageReadingTime
        self.mostCommonCategory = mostCommonCategory
        self.mostCommonDifficulty = mostCommonDifficulty
        self.learningStreak = learningStreak
        self.lastActivityDate = lastActivityDate
    }
}

// MARK: - Error Types
public enum VocabularyDataError: LocalizedError {
    case wordNotFound
    case invalidData
    case networkError
    case storageError
    case validationFailed([String])
    case operationNotSupported
    
    public var errorDescription: String? {
        switch self {
        case .wordNotFound:
            return "Vocabulary word not found"
        case .invalidData:
            return "Invalid vocabulary data provided"
        case .networkError:
            return "Network connection error"
        case .storageError:
            return "Data storage error"
        case .validationFailed(let errors):
            return "Validation failed: \(errors.joined(separator: ", "))"
        case .operationNotSupported:
            return "Operation not supported"
        }
    }
}

// MARK: - Backward Compatibility
public typealias VocabularyRepositoryProtocol = VocabularyDataManager
