//
//  VocabularyRepository.swift
//  Vocabulary
//
//  Created by Mohammed Balegh on 08/09/2025.
//

import Foundation
import Combine

/// Advanced vocabulary data repository with comprehensive learning management
/// Provides sample data and progress tracking for vocabulary learning
public final class VocabularyDataRepository: VocabularyDataManager {
    
    // MARK: - Published Properties
    @Published private var vocabularyList: [VocabularyWord] = []
    @Published private var learnedWords: Set<UUID> = []
    @Published private var learningProgress: LearningProgress = LearningProgress(totalWords: 0, learnedWords: 0)
    
    // MARK: - Publishers
    public var vocabularyPublisher: AnyPublisher<[VocabularyWord], Never> {
        $vocabularyList.eraseToAnyPublisher()
    }
    
    public var progressPublisher: AnyPublisher<LearningProgress, Never> {
        $learningProgress.eraseToAnyPublisher()
    }
    
    // MARK: - Private Properties
    private let userDefaults = UserDefaults.standard
    private let learnedWordsKey = "learnedVocabularyWords"
    private let streakKey = "learningStreak"
    private let lastLearningDateKey = "lastLearningDate"
    
    // MARK: - Initialization
    public init() {
        loadInitialData()
        loadLearnedWords()
        updateProgress()
    }
    
    // MARK: - Core Data Operations
    public func fetchAllVocabulary() async throws -> [VocabularyWord] {
        return vocabularyList
    }
    
    public func fetchVocabulary(by id: UUID) async throws -> VocabularyWord? {
        return vocabularyList.first { $0.id == id }
    }
    
    public func fetchVocabulary(by word: String) async throws -> VocabularyWord? {
        return vocabularyList.first { $0.word.lowercased() == word.lowercased() }
    }
    
    public func fetchVocabulary(by category: WordCategory) async throws -> [VocabularyWord] {
        return vocabularyList.filter { $0.category == category }
    }
    
    public func fetchVocabulary(by difficulty: DifficultyLevel) async throws -> [VocabularyWord] {
        return vocabularyList.filter { $0.difficultyLevel == difficulty }
    }
    
    // MARK: - Search and Filter Operations
    public func searchVocabulary(query: String) async throws -> [VocabularyWord] {
        let lowercaseQuery = query.lowercased()
        return vocabularyList.filter { vocabulary in
            vocabulary.word.lowercased().contains(lowercaseQuery) ||
            vocabulary.definition.lowercased().contains(lowercaseQuery) ||
            vocabulary.example.lowercased().contains(lowercaseQuery)
        }
    }
    
    public func filterVocabulary(by tags: Set<String>) async throws -> [VocabularyWord] {
        return vocabularyList.filter { vocabulary in
            !tags.isDisjoint(with: vocabulary.tags)
        }
    }
    
    public func getRandomVocabulary(count: Int) async throws -> [VocabularyWord] {
        let shuffled = vocabularyList.shuffled()
        return Array(shuffled.prefix(count))
    }
    
    public func getVocabularyByDifficulty(_ difficulty: DifficultyLevel, count: Int) async throws -> [VocabularyWord] {
        let filtered = vocabularyList.filter { $0.difficultyLevel == difficulty }
        return Array(filtered.prefix(count))
    }
    
    // MARK: - Progress Tracking
    public func markAsLearned(_ vocabularyId: UUID) async throws {
        learnedWords.insert(vocabularyId)
        saveLearnedWords()
        updateProgress()
    }
    
    public func markAsUnlearned(_ vocabularyId: UUID) async throws {
        learnedWords.remove(vocabularyId)
        saveLearnedWords()
        updateProgress()
    }
    
    public func getLearnedVocabulary() async throws -> Set<UUID> {
        return learnedWords
    }
    
    public func getLearningProgress() async throws -> LearningProgress {
        return learningProgress
    }
    
    // MARK: - Statistics and Analytics
    public func getVocabularyStatistics() async throws -> VocabularyStatistics {
        let totalWords = vocabularyList.count
        let learnedWordsCount = learnedWords.count
        let averageReadingTime = vocabularyList.reduce(0.0) { $0 + $1.estimatedReadingTime } / Double(totalWords)
        
        let categoryCounts = Dictionary(grouping: vocabularyList, by: { $0.category })
        let mostCommonCategory = categoryCounts.max { $0.value.count < $1.value.count }?.key
        
        let difficultyCounts = Dictionary(grouping: vocabularyList, by: { $0.difficultyLevel })
        let mostCommonDifficulty = difficultyCounts.max { $0.value.count < $1.value.count }?.key
        
        let streak = userDefaults.integer(forKey: streakKey)
        let lastActivityDate = userDefaults.object(forKey: lastLearningDateKey) as? Date
        
        return VocabularyStatistics(
            totalWords: totalWords,
            learnedWords: learnedWordsCount,
            averageReadingTime: averageReadingTime,
            mostCommonCategory: mostCommonCategory,
            mostCommonDifficulty: mostCommonDifficulty,
            learningStreak: streak,
            lastActivityDate: lastActivityDate
        )
    }
    
    public func getCategoryStatistics() async throws -> [WordCategory: Int] {
        return Dictionary(grouping: vocabularyList, by: { $0.category })
            .mapValues { $0.count }
    }
    
    public func getDifficultyStatistics() async throws -> [DifficultyLevel: Int] {
        return Dictionary(grouping: vocabularyList, by: { $0.difficultyLevel })
            .mapValues { $0.count }
    }
    
    // MARK: - Data Management
    public func addVocabulary(_ vocabulary: VocabularyWord) async throws {
        guard vocabulary.isValid else {
            throw VocabularyDataError.validationFailed(vocabulary.validationErrors)
        }
        
        vocabularyList.append(vocabulary)
        updateProgress()
    }
    
    public func updateVocabulary(_ vocabulary: VocabularyWord) async throws {
        guard vocabulary.isValid else {
            throw VocabularyDataError.validationFailed(vocabulary.validationErrors)
        }
        
        if let index = vocabularyList.firstIndex(where: { $0.id == vocabulary.id }) {
            vocabularyList[index] = vocabulary
            updateProgress()
        } else {
            throw VocabularyDataError.wordNotFound
        }
    }
    
    public func deleteVocabulary(_ id: UUID) async throws {
        vocabularyList.removeAll { $0.id == id }
        learnedWords.remove(id)
        saveLearnedWords()
        updateProgress()
    }
    
    public func clearAllData() async throws {
        vocabularyList.removeAll()
        learnedWords.removeAll()
        saveLearnedWords()
        updateProgress()
    }
    
    // MARK: - Private Methods
    private func loadInitialData() {
        vocabularyList = [
            VocabularyWord(
                word: "pragmatic",
                pronunciation: "præɡˈmætɪk",
                partOfSpeech: "adj.",
                definition: "Dealing with things in a practical and realistic way",
                example: "He took a pragmatic approach to solving the problem.",
                difficultyLevel: .intermediate,
                category: .general,
                tags: ["practical", "realistic", "approach"]
            ),
            VocabularyWord(
                word: "esoteric",
                pronunciation: "ˌesəˈterɪk",
                partOfSpeech: "adj.",
                definition: "Intended for or likely to be understood by only a small number of people",
                example: "The professor's esoteric theories were difficult for students to grasp.",
                difficultyLevel: .advanced,
                category: .academic,
                tags: ["obscure", "specialized", "complex"]
            ),
            VocabularyWord(
                word: "cognizant",
                pronunciation: "ˈkɑːɡnɪzənt",
                partOfSpeech: "adj.",
                definition: "Having knowledge or being aware of something",
                example: "She was fully cognizant of the risks involved in the project.",
                difficultyLevel: .intermediate,
                category: .general,
                tags: ["aware", "knowledgeable", "conscious"]
            ),
            VocabularyWord(
                word: "quintessential",
                pronunciation: "ˌkwɪntɪˈsenʃəl",
                partOfSpeech: "adj.",
                definition: "Representing the most perfect or typical example of a quality or class",
                example: "She was the quintessential hostess, always making her guests feel welcome.",
                difficultyLevel: .advanced,
                category: .general,
                tags: ["perfect", "typical", "exemplary"]
            ),
            VocabularyWord(
                word: "alacrity",
                pronunciation: "əˈlækrəti",
                partOfSpeech: "noun",
                definition: "Brisk and cheerful readiness",
                example: "She accepted the invitation with alacrity and enthusiasm.",
                difficultyLevel: .intermediate,
                category: .general,
                tags: ["eagerness", "readiness", "enthusiasm"]
            ),
            VocabularyWord(
                word: "SUCCESS",
                pronunciation: "",
                partOfSpeech: "",
                definition: "Congratulations! \n You've completed all vocabulary lessons for today!",
                example: "Great job on your amazing learning journey! Keep up the excellent work!",
                difficultyLevel: .beginner,
                category: .success,
                tags: ["achievement", "completion", "celebration"]
            )
        ]
    }
    
    private func loadLearnedWords() {
        if let data = userDefaults.data(forKey: learnedWordsKey),
           let decoded = try? JSONDecoder().decode(Set<UUID>.self, from: data) {
            learnedWords = decoded
        }
    }
    
    private func saveLearnedWords() {
        if let encoded = try? JSONEncoder().encode(learnedWords) {
            userDefaults.set(encoded, forKey: learnedWordsKey)
        }
    }
    
    private func updateProgress() {
        let totalWords = vocabularyList.filter { !$0.isSuccessCard }.count
        let learnedWordsCount = learnedWords.filter { id in
            vocabularyList.contains { $0.id == id && !$0.isSuccessCard }
        }.count
        
        learningProgress = LearningProgress(
            totalWords: totalWords,
            learnedWords: learnedWordsCount,
            currentStreak: userDefaults.integer(forKey: streakKey),
            lastLearningDate: userDefaults.object(forKey: lastLearningDateKey) as? Date
        )
    }
}

// MARK: - Backward Compatibility
public typealias VocabularyRepository = VocabularyDataRepository
