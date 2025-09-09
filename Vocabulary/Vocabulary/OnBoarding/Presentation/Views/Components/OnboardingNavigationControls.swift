//
//  OnboardingNavigationControls.swift
//  Vocabulary
//
//  Created by Mohammed Balegh on 06/09/2025.
//

import SwiftUI

struct OnboardingNavigationControls: View {
    let configuration: OnboardingFlowViewConfiguration
    let canGoBack: Bool
    let canSkip: Bool
    let onBack: () -> Void
    let onSkip: () -> Void
    
    var body: some View {
        HStack(spacing: configuration.navigationControlsSpacing) {
            if canGoBack {
                Button(action: onBack) {
                    HStack(spacing: 8) {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .font(configuration.backButtonFont)
                    .foregroundColor(configuration.backButtonColor)
                    .padding(.horizontal, configuration.backButtonHorizontalPadding)
                    .padding(.vertical, configuration.backButtonVerticalPadding)
                    .background(configuration.backButtonBackgroundColor)
                    .cornerRadius(configuration.backButtonCornerRadius)
                }
            }
            
            Spacer()
            
            if canSkip {
                Button(action: onSkip) {
                    Text("Skip")
                        .font(configuration.skipButtonFont)
                        .foregroundColor(configuration.skipButtonColor)
                        .padding(.horizontal, configuration.skipButtonHorizontalPadding)
                        .padding(.vertical, configuration.skipButtonVerticalPadding)
                        .background(configuration.skipButtonBackgroundColor)
                        .cornerRadius(configuration.skipButtonCornerRadius)
                }
            }
        }
        .padding(.horizontal, configuration.horizontalPadding)
        .padding(.top, configuration.navigationControlsTopPadding)
        .background(Color.clear)
    }
}
