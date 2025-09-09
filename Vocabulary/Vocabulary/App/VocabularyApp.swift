//
//  VocabularyApp.swift
//  Vocabulary
//
//  Created by Mohammed Balegh on 04/09/2025.
//

import SwiftUI
import SwiftData
import Lottie

/// Main entry point for the Vocabulary learning app
/// Manages the overall app lifecycle and navigation flow
@main
struct VocabularyApp: App {
    
    // MARK: - App Configuration
    private let dataModel = OnboardingDataModel.self
    
    var body: some Scene {
        WindowGroup {
            AppRootView()
                .modelContainer(for: dataModel)
                .preferredColorScheme(.light)
        }
    }
}

// MARK: - App Root Container
struct AppRootView: View {
    @State private var appState: AppState = .initializing
    
    var body: some View {
        Group {
            switch appState {
            case .initializing:
                SplashScreenView()
            case .onboarding:
                OnboardingContainerView()
            case .main:
                MainAppView()
            }
        }
        .onAppear {
            determineInitialState()
        }
    }
    
    private func determineInitialState() {
        // Check if onboarding is completed
        let onboardingCompleted = UserDefaults.standard.bool(forKey: "onboardingCompleted")

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.easeInOut(duration: 0.5)) {
                appState = onboardingCompleted ? .main : .onboarding
            }
        }
    }
}

// MARK: - App State Management
enum AppState {
    case initializing
    case onboarding
    case main
}

// MARK: - Splash Screen
struct SplashScreenView: View {
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 20) {
                LottieView(animation: .named("splash"))
                    .configure { lottie in
                        lottie.contentMode = .scaleAspectFit
                    }
                    .playbackMode(.playing(.toProgress(1, loopMode: .loop)))
                    .frame(width: 200, height: 200)
                    .padding(.vertical, 16)

                Text("Vocabulary")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
}

// MARK: - Main App View
struct MainAppView: View {
    var body: some View {
        MainView()
    }
}
