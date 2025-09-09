//
//  IntroViewModel.swift
//  Vocabulary
//
//  Created by Mohammed Balegh on 05/09/2025.
//

import SwiftUI
import Combine

/// Advanced introduction view model with comprehensive state management
/// Handles introduction screen logic, animations, and data coordination
@MainActor
public final class IntroViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published public private(set) var introItems: [IntroItem] = []
    @Published public private(set) var currentIndex: Int = 0
    @Published public private(set) var isLoading: Bool = false
    @Published public private(set) var errorMessage: String?
    @Published public private(set) var isAnimating: Bool = false
    @Published public private(set) var animationProgress: Double = 0.0
    
    // MARK: - Private Properties
    private let dataService: IntroDataManager
    private let configuration: IntroConfiguration
    private var animationTask: Task<Void, Never>?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    public init(
        dataProvider: IntroDataManager = IntroDataRepository(),
        configuration: IntroConfiguration = .default
    ) {
        self.dataService = dataProvider
        self.configuration = configuration
        
        setupObservers()
        initializeData()
    }
    
    // MARK: - Public Interface
    public var currentItem: IntroItem? {
        guard currentIndex < introItems.count else { return nil }
        return introItems[currentIndex]
    }
    
    public var hasNextItem: Bool {
        return currentIndex < introItems.count - 1
    }
    
    public var hasPreviousItem: Bool {
        return currentIndex > 0
    }
    
    public var totalItems: Int {
        return introItems.count
    }
    
    public var progressPercentage: Double {
        guard totalItems > 0 else { return 0.0 }
        return Double(currentIndex + 1) / Double(totalItems)
    }
    
    // MARK: - Data Management
    public func initializeData() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let items = try await dataService.fetchActiveIntroItems()
            introItems = items.sorted { $0.displayOrder < $1.displayOrder }
            currentIndex = 0
        } catch {
            errorMessage = "Failed to load introduction data: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    // MARK: - Navigation
    public func nextItem() {
        guard hasNextItem else { return }
        currentIndex += 1
        startAnimation()
    }
    
    public func previousItem() {
        guard hasPreviousItem else { return }
        currentIndex -= 1
        startAnimation()
    }
    
    public func goToItem(at index: Int) {
        guard index >= 0 && index < introItems.count else { return }
        currentIndex = index
        startAnimation()
    }
    
    // MARK: - Animation Control
    public func startAnimation() {
        stopAnimation()
        
        animationTask = Task {
            await performAnimationSequence()
        }
    }
    
    public func stopAnimation() {
        animationTask?.cancel()
        animationTask = nil
        isAnimating = false
        animationProgress = 0.0
    }
    
    public func pauseAnimation() {
        animationTask?.cancel()
        isAnimating = false
    }
    
    public func resumeAnimation() {
        startAnimation()
    }
    
    // MARK: - Utility Methods
    public func calculateTextWidth(for text: String) -> CGFloat {
        let font = UIFont.preferredFont(forTextStyle: .title2)
        let attributes = [NSAttributedString.Key.font: font]
        let size = NSString(string: text).size(withAttributes: attributes)
        return size.width + configuration.defaultTextPadding
    }
    
    public func calculateOptimalCircleSize(for text: String) -> CGFloat {
        let textWidth = calculateTextWidth(for: text)
        let baseSize = configuration.defaultCircleSize
        let scaleFactor = min(1.5, max(0.8, textWidth / 200))
        return baseSize * scaleFactor
    }
    
    // MARK: - Private Methods
    private func setupObservers() {
        dataService.introItemsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] items in
                self?.introItems = items.sorted { $0.displayOrder < $1.displayOrder }
            }
            .store(in: &cancellables)
    }
    
    private func initializeData() {
        Task {
            await initializeData()
        }
    }
    
    private func performAnimationSequence() async {
        isAnimating = true
        
        // Animation sequence
        for progress in stride(from: 0.0, through: 1.0, by: 0.1) {
            guard !Task.isCancelled else { return }
            
            animationProgress = progress
            
            try? await Task.sleep(nanoseconds: UInt64(configuration.defaultAnimationDuration * 100_000_000))
        }
        
        // Cycle delay
        try? await Task.sleep(nanoseconds: configuration.defaultCycleDelay)
        
        isAnimating = false
        
        // Auto-advance to next item
        if hasNextItem {
            nextItem()
        } else {
            // Reset to first item for continuous loop
            currentIndex = 0
        }
    }
}

// MARK: - Convenience Extensions
public extension IntroViewModel {
    /// Create a view model with fast animations
    static func fast(
        dataProvider: IntroDataManager = IntroDataRepository()
    ) -> IntroViewModel {
        return IntroViewModel(
            dataProvider: dataProvider,
            configuration: .fast
        )
    }
    
    /// Create a view model with slow animations
    static func slow(
        dataProvider: IntroDataManager = IntroDataRepository()
    ) -> IntroViewModel {
        return IntroViewModel(
            dataProvider: dataProvider,
            configuration: .slow
        )
    }
}
