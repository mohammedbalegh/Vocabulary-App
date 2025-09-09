//
//  OnboardingHeaderView.swift
//  Vocabulary
//
//  Created by Mohammed Balegh on 06/09/2025.
//

import SwiftUI

struct OnBoardingHeaderView: View {
    private let title: String
    @State private var hasAppeared = false
    
    init(title: String) {
        self.title = title
    }
    
    var body: some View {
        Text(title)
            .font(AppTypography.headerFont)
            .foregroundStyle(AppColors.primaryText)
            .multilineTextAlignment(.center)
            .scaleEffect(hasAppeared ? 1.0 : 0.6)
            .opacity(hasAppeared ? 1 : 0)
            .offset(y: hasAppeared ? 0 : -30)
            .padding(.horizontal, OnBoardingSpacing.headerHorizontal)
            .padding(.top, OnBoardingSpacing.headerTop)
            .shadow(color: .black.opacity(0.2), radius: 4, y: 2)
            .onAppear {
                withAnimation(AppAnimations.headerSpring) {
                    hasAppeared = true
                }
            }
    }
}
