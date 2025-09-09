//
//  OnboardingFlowView.swift
//  Vocabulary
//
//  Created by Mohammed Balegh on 06/09/2025.
//

import SwiftUI

/// Advanced onboarding flow view with comprehensive configuration and state management
public struct OnboardingFlowView: View {
    @StateObject private var viewModel: OnboardingFlowViewModel
    @Binding public var showWalkThrough: Bool
    public let configuration: OnboardingFlowViewConfiguration
    
    public init(
        showWalkThrough: Binding<Bool>,
        viewModel: OnboardingFlowViewModel,
        configuration: OnboardingFlowViewConfiguration = .default
    ) {
        self._showWalkThrough = showWalkThrough
        self._viewModel = StateObject(wrappedValue: viewModel)
        self.configuration = configuration
    }
    
    public var body: some View {
        GeometryReader { geometry in
            let size = geometry.size
            
            ZStack {
                backgroundLayer
                contentLayer(geometry: geometry)
            }
            .animation(configuration.stepTransitionAnimation, value: viewModel.activeStep)
            .offset(y: showWalkThrough ? 0 : size.height)
            .animation(configuration.entranceAnimation, value: showWalkThrough)
            .alert("Error", isPresented: .constant(viewModel.error != nil)) {
                Button("OK") {
                    viewModel.clearError()
                }
            } message: {
                Text(viewModel.error?.localizedDescription ?? "An error occurred")
            }
        }
    }
    
    // MARK: - Background Layer
    private var backgroundLayer: some View {
        configuration.backgroundColor
            .ignoresSafeArea()
            .overlay(
                configuration.backgroundOverlay
                    .opacity(configuration.backgroundOverlayOpacity)
            )
    }
    
    // MARK: - Content Layer
    private func contentLayer(geometry: GeometryProxy) -> some View {
        ZStack {
            VStack(spacing: 0) {
                if configuration.showProgressIndicator {
                    OnboardingProgressIndicator(
                        configuration: configuration,
                        activeStep: viewModel.activeStep,
                        progressPercentage: viewModel.progressPercentage
                    )
                }
                
                Spacer()
                
                OnboardingStepContent(
                    activeStep: viewModel.activeStep,
                    onboardingData: viewModel.onboardingData,
                    onUpdateUserReferral: viewModel.updateUserReferral,
                    onUpdateUserAge: viewModel.updateUserAge,
                    onUpdateUserGender: viewModel.updateUserGender,
                    onUpdateUserName: viewModel.updateUserName,
                    onUpdateUserGoals: viewModel.updateUserGoals,
                    onUpdateUserTopics: viewModel.updateUserTopics,
                    onAdvanceToNextStep: viewModel.advanceToNextStep,
                    onSkipCurrentStep: viewModel.skipCurrentStep
                )
                .frame(maxWidth: configuration.maxContentWidth)
                .padding(.horizontal, configuration.horizontalPadding)
                
                Spacer()
            }
            .padding(.vertical, configuration.verticalPadding)

            
            if configuration.showNavigationControls {
                VStack {
                    Spacer()
                    OnboardingNavigationControls(
                        configuration: configuration,
                        canGoBack: viewModel.canGoBack,
                        canSkip: viewModel.canSkip,
                        onBack: viewModel.navigateToPreviousStep,
                        onSkip: viewModel.skipCurrentStep
                    )
                    .background(Color.clear)
                }
                .padding(.vertical, configuration.verticalPadding)
            }
        }
    }
}

// MARK: - Convenience Extensions
public extension OnboardingFlowView {
    static func withDefaultConfiguration(
        showWalkThrough: Binding<Bool>,
        viewModel: OnboardingFlowViewModel
    ) -> OnboardingFlowView {
        OnboardingFlowView(
            showWalkThrough: showWalkThrough,
            viewModel: viewModel,
            configuration: .default
        )
    }
}
