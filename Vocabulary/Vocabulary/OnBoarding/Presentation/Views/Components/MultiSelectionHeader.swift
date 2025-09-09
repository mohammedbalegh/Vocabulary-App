//
//  MultiSelectionHeader.swift
//  Vocabulary
//
//  Created by Mohammed Balegh on 06/09/2025.
//

import SwiftUI

struct MultiSelectionHeader: View {
    let title: String
    let onSkip: (() -> Void)?
    let hasAppeared: Bool

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(height: 20)

            OnBoardingHeaderView(title: title)
                .shadow(color: .black, radius: 1, y: 3)
                .opacity(hasAppeared ? 1 : 0)
                .offset(y: hasAppeared ? 0 : -20)
                .animation(AppAnimations.headerSpring, value: hasAppeared)
        }
    }
}
