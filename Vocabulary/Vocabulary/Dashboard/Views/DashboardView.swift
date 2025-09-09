//
//  MainView.swift
//  Vocabulary
//
//  Created by Mohammed Balegh on 08/09/2025.
//

import SwiftUI
import Lottie
import AVFoundation
import Foundation

// MARK: - Main Configuration
public struct MainConfiguration {
    public let headerHeightMultiplier: CGFloat
    public let mainContentHeightMultiplier: CGFloat
    public let animationResponse: Double
    public let animationDamping: Double
    public let loadingAnimationDuration: Double
    public let headerAnimationDelay: Double
    public let progressAnimationDelay: Double
    public let streakAnimationDelay: Double
    public let voiceButtonAnimationDelay: Double
    
    public init(
        headerHeightMultiplier: CGFloat = 0.25,
        mainContentHeightMultiplier: CGFloat = 0.75,
        animationResponse: Double = 0.6,
        animationDamping: Double = 0.8,
        loadingAnimationDuration: Double = 0.5,
        headerAnimationDelay: Double = 0.2,
        progressAnimationDelay: Double = 0.2,
        streakAnimationDelay: Double = 0.3,
        voiceButtonAnimationDelay: Double = 0.4
    ) {
        self.headerHeightMultiplier = headerHeightMultiplier
        self.mainContentHeightMultiplier = mainContentHeightMultiplier
        self.animationResponse = animationResponse
        self.animationDamping = animationDamping
        self.loadingAnimationDuration = loadingAnimationDuration
        self.headerAnimationDelay = headerAnimationDelay
        self.progressAnimationDelay = progressAnimationDelay
        self.streakAnimationDelay = streakAnimationDelay
        self.voiceButtonAnimationDelay = voiceButtonAnimationDelay
    }
    
    public static let `default` = MainConfiguration()
    public static let compact = MainConfiguration(
        headerHeightMultiplier: 0.2,
        mainContentHeightMultiplier: 0.8
    )
    public static let spacious = MainConfiguration(
        headerHeightMultiplier: 0.3,
        mainContentHeightMultiplier: 0.7
    )
}

// MARK: - Interface State Management
public enum MainInterfaceState {
    case loading
    case content
    case empty
    case error(String)
}

public enum SuccessAlertState {
    case hidden
    case visible
}

// MARK: - Main View
public struct MainView: View {
    @StateObject private var viewModel: MainViewModel
    @State private var interfaceState: MainInterfaceState = .loading
    @State private var successAlertState: SuccessAlertState = .hidden
    @State private var isInitialized = false
    
    public let configuration: MainConfiguration
    
    public init(
        configuration: MainConfiguration = .default,
        dataProvider: VocabularyDataManager? = nil
    ) {
        self.configuration = configuration
        let provider = dataProvider ?? VocabularyDataRepository()
        self._viewModel = StateObject(wrappedValue: MainViewModel(dataProvider: provider))
    }
    
    public var body: some View {
        GeometryReader { geometry in
            ZStack {
                backgroundLayer
                contentLayer(geometry: geometry)
            }
        }
        .onAppear {
            handleViewAppearance()
        }
        .onChange(of: viewModel.isCompleted) { _, isCompleted in
            handleCompletionStateChange(isCompleted)
        }
    }
    
    // MARK: - View Components
    private var backgroundLayer: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                AppColorPalette.mainBackground,
                AppColorPalette.mainBackground.opacity(0.8)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
    
    private func contentLayer(geometry: GeometryProxy) -> some View {
        VocabularyLearningInterface(
            viewModel: viewModel,
            geometry: geometry,
            configuration: configuration
        )
    }
    
    // MARK: - Event Handlers
    private func handleViewAppearance() {
        guard !isInitialized else { return }
        isInitialized = true
        
        Task {
            await viewModel.initializeData()
            
            withAnimation(.easeInOut(duration: configuration.loadingAnimationDuration)) {
                switch viewModel.currentState {
                case .loading:
                    interfaceState = .loading
                case .loaded(let words):
                    interfaceState = words.isEmpty ? .empty : .content
                case .error(let error):
                    interfaceState = .error(error.localizedDescription)
                }
            }
        }
    }
    
    private func handleCompletionStateChange(_ isCompleted: Bool) {
        if isCompleted {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.spring(
                    response: configuration.animationResponse,
                    dampingFraction: configuration.animationDamping
                )) {
                    successAlertState = .visible
                }
            }
        }
    }
}
