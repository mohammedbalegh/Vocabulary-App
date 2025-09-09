//
//  SuccessStepView.swift
//  Vocabulary
//
//  Created by Mohammed Balegh on 06/09/2025.
//

import SwiftUI
import Lottie

struct TailorStepView: View {
    let title: String
    let animationName: String
    let onContinue: () -> Void
    
    @State private var titleVisible = false
    @State private var lottieVisible = false
    @State private var buttonVisible = false
    
    private let hapticProvider: HapticFeedbackProviding
    
    init(
        title: String,
        animationName: String,
        onContinue: @escaping () -> Void,
        hapticProvider: HapticFeedbackProviding = AdvancedHapticManager.shared
    ) {
        self.title = title
        self.animationName = animationName
        self.onContinue = onContinue
        self.hapticProvider = hapticProvider
    }
    
    var body: some View {
        VStack() {
            
            Spacer()
            
            LottieView(animation: .named(animationName))
                .configure { lottie in
                    lottie.contentMode = .scaleAspectFill
                }
                .playbackMode(.playing(.toProgress(1, loopMode: .loop)))
                .frame(maxWidth: .infinity, maxHeight: 400)
                .clipped()
                .scaleEffect(lottieVisible ? 1.0 : 0.3)
                .opacity(lottieVisible ? 1 : 0)
                .animation(
                    .spring(response: 1.0, dampingFraction: 0.7).delay(0.4),
                    value: lottieVisible
                )
                .padding(.bottom, 24)
            
            Text(title)
                .font(.title.bold())
                .multilineTextAlignment(.center)
                .foregroundStyle(AppColors.primaryText)
                .padding(.horizontal)
                .offset(y: titleVisible ? 0 : -50)
                .opacity(titleVisible ? 1 : 0)
                .animation(
                    .spring(response: 0.8, dampingFraction: 0.8).delay(0.2),
                    value: titleVisible
                )
                .padding(.bottom, 60)
            
            Spacer()
            
            ContinueButton(
                isEnabled: true,
                hasAppeared: buttonVisible,
                delay: 0.6,
                onTap: {
                    hapticProvider.provideMediumImpact()
                    onContinue()
                }
            )
        }
        .padding()
        .onAppear {
            titleVisible = true
            lottieVisible = true
            buttonVisible = true
        }
    }
}
