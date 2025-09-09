//
//  SampleIntros.swift
//  Vocabulary
//
//  Created by Mohammed Balegh on 05/09/2025.
//

import SwiftUI
import Combine

/// Advanced introduction data repository with comprehensive data management
/// Provides sample data and caching for introduction screen content
public final class IntroDataRepository: IntroDataManager {
    
    // MARK: - Published Properties
    @Published private var introItems: [IntroItem] = []
    
    // MARK: - Publishers
    public var introItemsPublisher: AnyPublisher<[IntroItem], Never> {
        $introItems.eraseToAnyPublisher()
    }
    
    // MARK: - Private Properties
    private let userDefaults = UserDefaults.standard
    private let introItemsKey = "introItems"
    private let lastUpdateKey = "lastIntroUpdate"
    private let configuration: IntroConfiguration
    
    // MARK: - Initialization
    public init(configuration: IntroConfiguration = .default) {
        self.configuration = configuration
        loadInitialData()
    }
    
    // MARK: - Core Data Operations
    public func fetchAllIntroItems() async throws -> [IntroItem] {
        return introItems
    }
    
    public func fetchIntroItem(by id: UUID) async throws -> IntroItem? {
        return introItems.first { $0.id == id }
    }
    
    public func fetchIntroItem(by text: String) async throws -> IntroItem? {
        return introItems.first { $0.text.lowercased() == text.lowercased() }
    }
    
    public func fetchActiveIntroItems() async throws -> [IntroItem] {
        return introItems.filter { $0.isActive }
    }
    
    public func fetchIntroItemsByOrder() async throws -> [IntroItem] {
        return introItems.sorted { $0.displayOrder < $1.displayOrder }
    }
    
    // MARK: - Search and Filter Operations
    public func searchIntroItems(query: String) async throws -> [IntroItem] {
        let lowercaseQuery = query.lowercased()
        return introItems.filter { item in
            item.text.lowercased().contains(lowercaseQuery)
        }
    }
    
    public func filterIntroItems(by isActive: Bool) async throws -> [IntroItem] {
        return introItems.filter { $0.isActive == isActive }
    }
    
    public func getRandomIntroItems(count: Int) async throws -> [IntroItem] {
        let shuffled = introItems.shuffled()
        return Array(shuffled.prefix(count))
    }
    
    // MARK: - Data Management
    public func addIntroItem(_ item: IntroItem) async throws {
        guard item.isValid else {
            throw IntroDataError.validationFailed(item.validationErrors)
        }
        
        guard introItems.count < configuration.maxIntroItems else {
            throw IntroDataError.operationNotSupported
        }
        
        introItems.append(item)
        saveIntroItems()
    }
    
    public func updateIntroItem(_ item: IntroItem) async throws {
        guard item.isValid else {
            throw IntroDataError.validationFailed(item.validationErrors)
        }
        
        if let index = introItems.firstIndex(where: { $0.id == item.id }) {
            introItems[index] = item
            saveIntroItems()
        } else {
            throw IntroDataError.itemNotFound
        }
    }
    
    public func deleteIntroItem(_ id: UUID) async throws {
        introItems.removeAll { $0.id == id }
        saveIntroItems()
    }
    
    public func clearAllData() async throws {
        introItems.removeAll()
        saveIntroItems()
    }
    
    // MARK: - Private Methods
    private func loadInitialData() {
        introItems = [
            IntroItem.create(
                text: "Learn Smarter",
                textColor: Color(hexString: "000000"),
                circleColor: Color(hexString: "000000"),
                backgroundColor: Color(hexString: "FFEFD3"),
                displayOrder: 1
            ),
            IntroItem.create(
                text: "Daily vocabulary",
                textColor: Color(hexString: "FFEFD3"),
                circleColor: Color(hexString: "FFEFD3"),
                backgroundColor: Color(hexString: "294C60"),
                displayOrder: 2
            ),
            IntroItem.create(
                text: "10,000+ words",
                textColor: Color(hexString: "294C60"),
                circleColor: Color(hexString: "294C60"),
                backgroundColor: Color(hexString: "FFC49B"),
                displayOrder: 3
            )
        ]
        
        loadPersistedData()
    }
    
    private func loadPersistedData() {
        if let data = userDefaults.data(forKey: introItemsKey),
           let decoded = try? JSONDecoder().decode([IntroItem].self, from: data) {
            introItems = decoded
        }
    }
    
    private func saveIntroItems() {
        if let encoded = try? JSONEncoder().encode(introItems) {
            userDefaults.set(encoded, forKey: introItemsKey)
            userDefaults.set(Date(), forKey: lastUpdateKey)
        }
    }
}

// MARK: - Backward Compatibility
public typealias IntroDataProvider = IntroDataRepository
