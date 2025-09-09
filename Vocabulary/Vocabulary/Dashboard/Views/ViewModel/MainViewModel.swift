//
//  DashboardViewModel.swift
//  Vocabulary
//
//  Created by mohammed balegh on 07/09/2025.
//


import Foundation

@MainActor
public final class MainViewModel: ObservableObject {
    @Published public private(set) var vocabularyList: [VocabularyWord] = []
    @Published public var activeIndex: Int = 0
    @Published public private(set) var completedWords: Set<UUID> = []
    @Published public private(set) var isLoading: Bool = false
    @Published public private(set) var errorMessage: String?
    @Published public private(set) var currentVoice: SpeechAccent
    @Published public private(set) var isPlayingSpeech = false
    @Published public private(set) var currentStreak: Int = 0
    @Published public private(set) var motivationalMessage: String = "Keep learning! 🌟"
    @Published public private(set) var isCompleted: Bool = false
    
    private let dataService: VocabularyDataManager
    private let soundManager: SpeechEngineManager
    private let hapticManager: AdvancedHapticManager
    
    public enum ViewModelState {
        case loading
        case loaded([VocabularyWord])
        case error(Error)
    }
    
    public var currentState: ViewModelState {
        if isLoading {
            return .loading
        } else if let errorMessage = errorMessage, !errorMessage.isEmpty {
            return .error(VocabularyDataError.storageError)
        } else {
            return .loaded(vocabularyList)
        }
    }
    
    public init(dataProvider: VocabularyDataManager) {
        self.dataService = dataProvider
        self.soundManager = SpeechEngineManager()
        self.hapticManager = AdvancedHapticManager.shared
        self.currentVoice = soundManager.selectedAccent
        
        setupObservers()
        initializeStreakTracking()
    }
    
    public var activeWord: VocabularyWord? {
        guard activeIndex < vocabularyList.count else { return nil }
        return vocabularyList[activeIndex]
    }
    
    // MARK: - Progress Tracking
    private var totalVocabularyCards: Int { 5 }
    
    public var completionCount: Int {
        completedWords.filter { wordId in
            vocabularyList.first { $0.id == wordId }?.word != "SUCCESS"
        }.count
    }
    
    public var completionPercentage: Double {
        guard totalVocabularyCards > 0 else { return 0.0 }
        return Double(completionCount) / Double(totalVocabularyCards)
    }
    
    public var progressDisplayText: String {
        "\(completionCount) of \(totalVocabularyCards)"
    }
    
    // MARK: - Data Management
    public func initializeData() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let words = try await dataService.fetchAllVocabulary()
            vocabularyList = words
            updateCompletionState()
        } catch {
            errorMessage = "Failed to load vocabulary data: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    // MARK: - Word Management
    public func markWordAsLearned(at index: Int) {
        guard index < vocabularyList.count else { return }
        let word = vocabularyList[index]
        
        if !completedWords.contains(word.id) {
        completedWords.insert(word.id)
            soundManager.playNotificationSound()
            hapticManager.triggerImpactFeedback(style: .medium)
            updateCompletionState()
        }
    }
    
    public func markWordAsUnlearned(at index: Int) {
        guard index < vocabularyList.count else { return }
        let word = vocabularyList[index]
        
        if completedWords.contains(word.id) {
            completedWords.remove(word.id)
            hapticManager.triggerImpactFeedback(style: .light)
            updateCompletionState()
        }
    }
    
    // MARK: - Audio Management
    public func playWordPronunciation() {
        guard let word = activeWord else { return }
        soundManager.speakText(word.word)
    }
    
    public func setVoice(_ voice: SpeechAccent) {
        soundManager.updateAccent(voice)
        currentVoice = voice
    }
    
    // MARK: - Feedback Management
    public func provideSuccessFeedback() {
        hapticManager.triggerSuccessSequence()
    }
    
    // MARK: - Streak Tracking
    private func initializeStreakTracking() {
        updateStreak()
        updateMotivationalMessage()
    }
    
    private func updateStreak() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        let lastLearningDateKey = "lastLearningDate"
        let streakCountKey = "streakCount"
        
        if let lastDateString = UserDefaults.standard.string(forKey: lastLearningDateKey),
           let lastDate = ISO8601DateFormatter().date(from: lastDateString) {
            
            let lastLearningDay = calendar.startOfDay(for: lastDate)
            let daysDifference = calendar.dateComponents([.day], from: lastLearningDay, to: today).day ?? 0
            
            if daysDifference == 1 {
                let currentStreak = UserDefaults.standard.integer(forKey: streakCountKey)
                self.currentStreak = currentStreak + 1
                UserDefaults.standard.set(self.currentStreak, forKey: streakCountKey)
            } else if daysDifference == 0 {
                self.currentStreak = UserDefaults.standard.integer(forKey: streakCountKey)
            } else {
                self.currentStreak = 1
                UserDefaults.standard.set(self.currentStreak, forKey: streakCountKey)
            }
        } else {
            self.currentStreak = 1
            UserDefaults.standard.set(self.currentStreak, forKey: streakCountKey)
        }
        
        UserDefaults.standard.set(ISO8601DateFormatter().string(from: today), forKey: lastLearningDateKey)
    }
    
    private func updateMotivationalMessage() {
        let messages = [
            1: "Great start! 🌟",
            2: "Two days strong! 💪",
            3: "Three in a row! 🔥",
            4: "Four day streak! 🚀",
            5: "Five days! Amazing! ⭐",
            6: "Six day champion! 👑",
            7: "One week streak! 🏆",
            8: "Eight days! Incredible! 🌈",
            9: "Nine day master! 🎯",
            10: "Ten days! Legend! 🦄"
        ]
        
        if currentStreak >= 10 {
            motivationalMessage = "🔥 \(currentStreak) day streak! You're unstoppable! 🦄"
        } else {
            motivationalMessage = messages[currentStreak] ?? "Keep learning! 🌟"
        }
    }
    
    public func recordLearningActivity() {
        updateStreak()
        updateMotivationalMessage()
    }
    
    // MARK: - Private Helpers
    private func setupObservers() {
        soundManager.$isCurrentlySpeaking
            .assign(to: &$isPlayingSpeech)
    }
    
    private func updateCompletionState() {
        isCompleted = completionCount >= totalVocabularyCards
    }
}

// MARK: - Convenience Extensions
public extension MainView {
    /// Create a compact dashboard
    static func compact(
        dataProvider: VocabularyDataManager? = nil
    ) -> MainView {
        MainView(
            configuration: .compact,
            dataProvider: dataProvider
        )
    }
    
    /// Create a spacious dashboard
    static func spacious(
        dataProvider: VocabularyDataManager? = nil
    ) -> MainView {
        MainView(
            configuration: .spacious,
            dataProvider: dataProvider
        )
    }
}
