//
//  AnimatedOptionsView.swift
//  Vocabulary
//
//  Created by Mohammed Balegh on 06/09/2025.
//

import SwiftUI

// MARK: - Generic Animated Options View
struct AnimatedOptionsView<T: OnboardingOption>: View {
    let title: String
    let options: [T]
    @Binding var selected: T?
    let onSelect: () -> Void
    
    @State private var hasAppeared = false
    
    private let selectionDelay: TimeInterval = 0.5
    private let staggerDelay: TimeInterval = 0.1
    
    var body: some View {
        ScrollView {
            VStack(spacing: 45) {
                OnBoardingHeaderView(title: title)
                VStack(spacing: 16) {
                    ForEach(Array(options.enumerated()), id: \.element) { index, option in
                        OptionButton(
                            title: option.rawValue,
                            isSelected: selected == option
                        ) {
                            handleSelection(option)
                        }
                        .opacity(hasAppeared ? 1 : 0)
                        .offset(y: hasAppeared ? 0 : 20)
                        .animation(
                            .easeIn(duration: 0.4)
                                .delay(Double(index) * staggerDelay),
                            value: hasAppeared
                        )
                    }
                }

            }
            .padding(.horizontal, 20)
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
    
    private func handleSelection(_ option: T) {
        selected = option
        
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            onSelect()
        }
    }
}
