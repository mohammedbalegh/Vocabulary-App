//
//  MultiSelectionStepView.swift
//  Vocabulary
//
//  Created by Mohammed Balegh on 06/09/2025.
//

import SwiftUI

// MARK: - Generic Multi-Selection Step View
struct MultiSelectionStepView<T: OnboardingOption>: View {
    @StateObject var viewModel: MultiSelectionViewModel<T>
    @State private var hasAppeared = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                MultiSelectionHeader(title: viewModel.title,
                                     onSkip: viewModel.skipAction,
                                     hasAppeared: hasAppeared)
                
                MultiOptionListView(viewModel: viewModel,
                                    hasAppeared: hasAppeared)
                
                // Continue Button
                ContinueButton(
                    isEnabled: viewModel.canContinue,
                    hasAppeared: hasAppeared,
                    delay: Double(viewModel.options.count) * 0.1 + 0.5,
                    onTap: viewModel.continueAction
                )
                .disabled(viewModel.isProcessing)
                
            }
        }
        .onAppear {
            withAnimation {
                hasAppeared = true
            }
        }
        .onDisappear {
            hasAppeared = false
        }
    }
}

// MARK: - Goals Step View
struct GoalsStepView: View {
    @StateObject var viewModel: MultiSelectionViewModel<GoalsOptions>
    
    var body: some View {
        MultiSelectionStepView(viewModel: viewModel)
    }
}

// MARK: - Topics Step View
struct TopicsStepView: View {
    @StateObject var viewModel: MultiSelectionViewModel<TopicsOptions>
    
    var body: some View {
        MultiSelectionStepView(viewModel: viewModel)
    }
}

struct MultiOptionListView<T: OnboardingOption>: View {
    @ObservedObject var viewModel: MultiSelectionViewModel<T>
    let hasAppeared: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            ForEach(Array(viewModel.options.enumerated()), id: \.element) { index , option in
                MultiOptionButton(title: option.rawValue,
                                  isSelected: viewModel.selectedOptions.contains(option),
                                  action: {viewModel.toggleOption(option)})
                .opacity(hasAppeared ? 1 : 0)
                .offset(y: hasAppeared ? 0 : 20)
                .animation(
                    AppAnimations.defaultEaseOut
                        .delay(Double(index) * 0.1 + 0.3),
                    value: hasAppeared
                )
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 32)
        .padding(.bottom, 120)
    }
}
