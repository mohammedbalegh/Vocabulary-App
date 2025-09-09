//
//  OnboardingContainerView.swift
//  Vocabulary
//
//  Created by Mohammed Balegh on 06/09/2025.
//

import SwiftUI

struct OnboardingContainerView: View {
    @State private var showWalkthrough = false
    @State private var isOnboardingComplete = false
    
    var body: some View {
        ZStack {
            if isOnboardingComplete {
                MainView()
            } else {
                ZStack {
                    IntroView(showWalkThrough: $showWalkthrough)
                    
                    OnboardingFlowView(
                        showWalkThrough: $showWalkthrough,
                        viewModel: OnboardingFlowViewModel(
                            saveDataUseCase: SaveOnboardingDataUseCase(
                                repository: OnboardingRepository(
                                    localDataSource: try! OnboardingLocalDataSource()
                                )
                            ),
                            repository: OnboardingRepository(
                                localDataSource: try! OnboardingLocalDataSource()
                            ),
                            onboardingCompleted: {
                                withAnimation {
                                    isOnboardingComplete = true
                                }
                            }
                        )
                    )
                }
            }
        }
        .animation(
            .interactiveSpring(
                response: 0.85,
                dampingFraction: 0.85,
                blendDuration: 0.85
            ),
            value: showWalkthrough
        )
        .background(AppColors.background)
    }
}
