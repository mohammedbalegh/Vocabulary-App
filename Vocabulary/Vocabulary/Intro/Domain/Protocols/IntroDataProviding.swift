//
//  IntroDataProviding.swift
//  Vocabulary
//
//  Created by Mohammed Balegh on 05/09/2025.
//

import Foundation
import Combine

/// Comprehensive protocol for introduction data management
/// Defines all operations needed for introduction screen data handling
public protocol IntroDataManager {
    
    // MARK: - Core Data Operations
    func fetchAllIntroItems() async throws -> [IntroItem]
    func fetchIntroItem(by id: UUID) async throws -> IntroItem?
    func fetchIntroItem(by text: String) async throws -> IntroItem?
    func fetchActiveIntroItems() async throws -> [IntroItem]
    func fetchIntroItemsByOrder() async throws -> [IntroItem]
    
    // MARK: - Search and Filter Operations
    func searchIntroItems(query: String) async throws -> [IntroItem]
    func filterIntroItems(by isActive: Bool) async throws -> [IntroItem]
    func getRandomIntroItems(count: Int) async throws -> [IntroItem]
    
    // MARK: - Data Management
    func addIntroItem(_ item: IntroItem) async throws
    func updateIntroItem(_ item: IntroItem) async throws
    func deleteIntroItem(_ id: UUID) async throws
    func clearAllData() async throws
    
    // MARK: - Reactive Updates
    var introItemsPublisher: AnyPublisher<[IntroItem], Never> { get }
}

// MARK: - Supporting Types
public struct IntroConfiguration {
    public let defaultAnimationDuration: Double
    public let defaultDelayBetweenAnimations: UInt64
    public let defaultCycleDelay: UInt64
    public let defaultCircleSize: CGFloat
    public let defaultCornerRadius: CGFloat
    public let defaultTextPadding: CGFloat
    public let maxIntroItems: Int
    public let cacheExpirationTime: TimeInterval
    
    public init(
        defaultAnimationDuration: Double = 0.8,
        defaultDelayBetweenAnimations: UInt64 = 1_000_000_000,
        defaultCycleDelay: UInt64 = 2_000_000_000,
        defaultCircleSize: CGFloat = 45,
        defaultCornerRadius: CGFloat = 25,
        defaultTextPadding: CGFloat = 25,
        maxIntroItems: Int = 10,
        cacheExpirationTime: TimeInterval = 300 // 5 minutes
    ) {
        self.defaultAnimationDuration = defaultAnimationDuration
        self.defaultDelayBetweenAnimations = defaultDelayBetweenAnimations
        self.defaultCycleDelay = defaultCycleDelay
        self.defaultCircleSize = defaultCircleSize
        self.defaultCornerRadius = defaultCornerRadius
        self.defaultTextPadding = defaultTextPadding
        self.maxIntroItems = maxIntroItems
        self.cacheExpirationTime = cacheExpirationTime
    }
    
    public static let `default` = IntroConfiguration()
    public static let fast = IntroConfiguration(
        defaultAnimationDuration: 0.5,
        defaultDelayBetweenAnimations: 500_000_000,
        defaultCycleDelay: 1_000_000_000
    )
    public static let slow = IntroConfiguration(
        defaultAnimationDuration: 1.2,
        defaultDelayBetweenAnimations: 2_000_000_000,
        defaultCycleDelay: 3_000_000_000
    )
}

public struct IntroStatistics {
    public let totalItems: Int
    public let activeItems: Int
    public let averageTextLength: Double
    public let mostCommonColor: String?
    public let lastUpdatedDate: Date?
    
    public init(
        totalItems: Int,
        activeItems: Int,
        averageTextLength: Double,
        mostCommonColor: String? = nil,
        lastUpdatedDate: Date? = nil
    ) {
        self.totalItems = totalItems
        self.activeItems = activeItems
        self.averageTextLength = averageTextLength
        self.mostCommonColor = mostCommonColor
        self.lastUpdatedDate = lastUpdatedDate
    }
}

// MARK: - Error Types
public enum IntroDataError: LocalizedError {
    case itemNotFound
    case invalidData
    case networkError
    case storageError
    case validationFailed([String])
    case operationNotSupported
    case configurationError
    
    public var errorDescription: String? {
        switch self {
        case .itemNotFound:
            return "Introduction item not found"
        case .invalidData:
            return "Invalid introduction data provided"
        case .networkError:
            return "Network connection error"
        case .storageError:
            return "Data storage error"
        case .validationFailed(let errors):
            return "Validation failed: \(errors.joined(separator: ", "))"
        case .operationNotSupported:
            return "Operation not supported"
        case .configurationError:
            return "Configuration error"
        }
    }
}

// MARK: - Backward Compatibility
public typealias IntroDataProviding = IntroDataManager
