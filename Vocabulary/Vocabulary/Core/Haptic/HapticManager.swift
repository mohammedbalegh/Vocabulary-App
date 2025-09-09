//
//  HapticManager.swift
//  Vocabulary
//
//  Created by Mohammed Balegh on 08/09/2025.
//

import UIKit
import SwiftUI

// MARK: - Haptic Feedback Protocol
public protocol TactileFeedbackProvider {
    nonisolated func triggerImpactFeedback(style: UIImpactFeedbackGenerator.FeedbackStyle)
    nonisolated func triggerNotificationFeedback(type: UINotificationFeedbackGenerator.FeedbackType)
    nonisolated func triggerSelectionFeedback()
    nonisolated func triggerSuccessSequence()
    nonisolated func triggerErrorSequence()
    nonisolated func provideLightImpact()
    nonisolated func provideMediumImpact()
    nonisolated func provideSuccessFeedback()
}

// MARK: - Haptic Feedback Types
public enum HapticFeedbackType {
    case light
    case medium
    case heavy
    case success
    case warning
    case error
    case selection
}

// MARK: - Advanced Haptic Manager
public final class AdvancedHapticManager: TactileFeedbackProvider {
    
    // MARK: - Singleton
    public static let shared = AdvancedHapticManager()
    
    // MARK: - Private Properties
    private let impactGenerator = UIImpactFeedbackGenerator()
    private let notificationGenerator = UINotificationFeedbackGenerator()
    private let selectionGenerator = UISelectionFeedbackGenerator()
    
    // MARK: - Configuration
    private struct HapticConfiguration {
        static let successDelay: TimeInterval = 0.1
        static let errorDelay: TimeInterval = 0.15
        static let sequenceDelay: TimeInterval = 0.2
    }
    
    // MARK: - Initialization
    public init() {
        prepareGenerators()
    }
    
    // MARK: - Public Interface
    public func triggerFeedback(_ type: HapticFeedbackType) {
        guard UIDevice.current.userInterfaceIdiom == .phone else { return }
        
        switch type {
        case .light:
            triggerImpactFeedback(style: .light)
        case .medium:
            triggerImpactFeedback(style: .medium)
        case .heavy:
            triggerImpactFeedback(style: .heavy)
        case .success:
            triggerSuccessSequence()
        case .warning:
            triggerNotificationFeedback(type: .warning)
        case .error:
            triggerErrorSequence()
        case .selection:
            triggerSelectionFeedback()
        }
    }
    
    public nonisolated func triggerImpactFeedback(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        Task { @MainActor in
            let generator = UIImpactFeedbackGenerator(style: style)
            generator.prepare()
            generator.impactOccurred()
        }
    }
    
    public nonisolated func triggerNotificationFeedback(type: UINotificationFeedbackGenerator.FeedbackType) {
        Task { @MainActor in
            notificationGenerator.prepare()
            notificationGenerator.notificationOccurred(type)
        }
    }
    
    public nonisolated func triggerSelectionFeedback() {
        Task { @MainActor in
            selectionGenerator.prepare()
            selectionGenerator.selectionChanged()
        }
    }
    
    public nonisolated func triggerSuccessSequence() {
        // Heavy impact followed by success notification
        triggerImpactFeedback(style: .heavy)
        
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: UInt64(HapticConfiguration.successDelay * 1_000_000_000))
            triggerNotificationFeedback(type: .success)
        }
    }
    
    public nonisolated func triggerErrorSequence() {
        // Heavy impact followed by error notification
        triggerImpactFeedback(style: .heavy)
        
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: UInt64(HapticConfiguration.errorDelay * 1_000_000_000))
            triggerNotificationFeedback(type: .error)
        }
    }
    
    // MARK: - Custom Sequences
    public func triggerCustomSequence(_ feedbacks: [HapticFeedbackType], delays: [TimeInterval] = []) {
        guard !feedbacks.isEmpty else { return }
        
        for (index, feedback) in feedbacks.enumerated() {
            let delay = index < delays.count ? delays[index] : HapticConfiguration.sequenceDelay
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay * Double(index)) { [weak self] in
                self?.triggerFeedback(feedback)
            }
        }
    }
    
    // MARK: - Private Methods
    private func prepareGenerators() {
        impactGenerator.prepare()
        notificationGenerator.prepare()
        selectionGenerator.prepare()
    }
}

// MARK: - Convenience Extensions
public extension AdvancedHapticManager {
    
    /// Quick access methods for common feedback patterns
    nonisolated func buttonPress() {
        Task { @MainActor in
            triggerFeedback(.light)
        }
    }
    
    nonisolated func buttonRelease() {
        Task { @MainActor in
            triggerFeedback(.medium)
        }
    }
    
    nonisolated func cardFlip() {
        Task { @MainActor in
            triggerFeedback(.selection)
        }
    }
    
    nonisolated func achievement() {
        triggerSuccessSequence()
    }
    
    nonisolated func validationError() {
        triggerErrorSequence()
    }
}

// MARK: - Backward Compatibility
public typealias HapticFeedbackProviding = TactileFeedbackProvider
public typealias HapticFeedbackManager = AdvancedHapticManager

// MARK: - Legacy Support
public extension AdvancedHapticManager {
    nonisolated func provideLightImpact() {
        Task { @MainActor in
            triggerFeedback(.light)
        }
    }
    
    nonisolated func provideMediumImpact() {
        Task { @MainActor in
            triggerFeedback(.medium)
        }
    }
    
    nonisolated func provideSuccessFeedback() {
        triggerSuccessSequence()
    }
}
