//
//  Vocabulary.swift
//  Vocabulary
//
//  Created by Mohammed Balegh on 08/09/2025.
//

import Foundation

/// Represents a vocabulary word with comprehensive learning information
/// Provides structured data for vocabulary learning and progress tracking
public struct VocabularyWord: Identifiable, Hashable, Codable {
    
    // MARK: - Core Properties
    public let id: UUID
    public let word: String
    public let pronunciation: String
    public let partOfSpeech: String
    public let definition: String
    public let example: String
    
    // MARK: - Learning Metadata
    public let difficultyLevel: DifficultyLevel
    public let category: WordCategory
    public let tags: Set<String>
    public let createdAt: Date
    public let updatedAt: Date
    
    // MARK: - Initialization
    public init(
        word: String,
        pronunciation: String,
        partOfSpeech: String,
        definition: String,
        example: String,
        difficultyLevel: DifficultyLevel = .intermediate,
        category: WordCategory = .general,
        tags: Set<String> = [],
        id: UUID = UUID(),
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.word = word
        self.pronunciation = pronunciation
        self.partOfSpeech = partOfSpeech
        self.definition = definition
        self.example = example
        self.difficultyLevel = difficultyLevel
        self.category = category
        self.tags = tags
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    // MARK: - Computed Properties
    public var displayTitle: String {
        return word.capitalized
    }
    
    public var phoneticNotation: String {
        return pronunciation.isEmpty ? word : pronunciation
    }
    
    public var fullDefinition: String {
        return "(\(partOfSpeech)) \(definition)"
    }
    
    public var isSuccessCard: Bool {
        return word.uppercased() == "SUCCESS"
    }
    
    public var estimatedReadingTime: TimeInterval {
        let wordsPerMinute = 200.0
        let wordCount = Double(definition.split(separator: " ").count + example.split(separator: " ").count)
        return (wordCount / wordsPerMinute) * 60.0
    }
}

// MARK: - Supporting Enums
public enum DifficultyLevel: String, CaseIterable, Codable {
    case beginner = "beginner"
    case intermediate = "intermediate"
    case advanced = "advanced"
    case expert = "expert"
    
    public var displayName: String {
        return rawValue.capitalized
    }
    
    public var color: String {
        switch self {
        case .beginner: return "green"
        case .intermediate: return "blue"
        case .advanced: return "orange"
        case .expert: return "red"
        }
    }
}

public enum WordCategory: String, CaseIterable, Codable {
    case general = "general"
    case academic = "academic"
    case business = "business"
    case technology = "technology"
    case science = "science"
    case arts = "arts"
    case success = "success"
    
    public var displayName: String {
        return rawValue.capitalized
    }
    
    public var icon: String {
        switch self {
        case .general: return "book"
        case .academic: return "graduationcap"
        case .business: return "briefcase"
        case .technology: return "laptopcomputer"
        case .science: return "atom"
        case .arts: return "paintbrush"
        case .success: return "star.fill"
        }
    }
}

// MARK: - Validation
public extension VocabularyWord {
    
    var isValid: Bool {
        return !word.isEmpty &&
               !definition.isEmpty &&
               !example.isEmpty &&
               word.count >= 2 &&
               definition.count >= 10 &&
               example.count >= 10
    }
    
    var validationErrors: [String] {
        var errors: [String] = []
        
        if word.isEmpty {
            errors.append("Word cannot be empty")
        } else if word.count < 2 {
            errors.append("Word must be at least 2 characters")
        }
        
        if definition.isEmpty {
            errors.append("Definition cannot be empty")
        } else if definition.count < 10 {
            errors.append("Definition must be at least 10 characters")
        }
        
        if example.isEmpty {
            errors.append("Example cannot be empty")
        } else if example.count < 10 {
            errors.append("Example must be at least 10 characters")
        }
        
        return errors
    }
}

// MARK: - Backward Compatibility
public typealias Vocabulary = VocabularyWord
