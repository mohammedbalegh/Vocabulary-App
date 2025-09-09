//
//  OnboardingProgressIndicator.swift
//  Vocabulary
//
//  Created by Mohammed Balegh on 06/09/2025.
//

import SwiftUI

struct OnboardingProgressIndicator: View {
    let configuration: OnboardingFlowViewConfiguration
    let activeStep: OnboardingStep
    let progressPercentage: Double
    
    var body: some View {
        VStack(spacing: configuration.progressIndicatorSpacing) {
            HStack {
                Text("Step \(activeStep.index + 1) of \(OnboardingStep.allCases.count)")
                    .font(configuration.progressTextFont)
                    .foregroundColor(configuration.progressTextColor)
                
                Spacer()
                
                Text("\(Int(progressPercentage * 100))%")
                    .font(configuration.progressTextFont)
                    .foregroundColor(configuration.progressTextColor)
            }
            
            ProgressView(
                progress: progressPercentage,
                text: "Step \(activeStep.rawValue + 1) of \(OnboardingStep.allCases.count)"
            )
                .progressViewStyle(LinearProgressViewStyle(tint: configuration.progressBarColor))
                .scaleEffect(x: 1, y: configuration.progressBarHeight, anchor: UnitPoint.center)
        }
        .padding(.horizontal, configuration.horizontalPadding)
        .padding(.bottom, configuration.progressIndicatorBottomPadding)
    }
}
