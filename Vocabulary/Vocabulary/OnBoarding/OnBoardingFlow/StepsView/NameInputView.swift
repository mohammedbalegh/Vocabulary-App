//
//  NameInputView.swift
//  Vocabulary
//
//  Created by Mohammed Balegh on 06/09/2025.
//

import SwiftUI

// MARK: - Main
struct NameInputView: View {
    @State private var name: String = ""
    @FocusState private var isTextFieldFocused: Bool
    @State private var hasAppeared = false

    let title: String
    let onContinue: () -> Void
    let onSkip: () -> Void

    var body: some View {
        VStack {
            NameInputHeader(title: title, hasAppeared: hasAppeared, onSkip: onSkip)

            VStack(spacing: 24) {
                NameTextField(
                    name: $name,
                    isFocused: $isTextFieldFocused
                )
                .padding(.top, 32)
            }
            .padding(.top, 60)

            ContinueButton(
                isEnabled: !name.trimmingCharacters(in: .whitespaces).isEmpty,
                hasAppeared: hasAppeared,
                delay: 0.6,
                onTap: onContinue
            )
            .padding(.top, 50)

            Spacer()
        }
        .padding(.horizontal, 20)
        .background(AppColors.background)
        .ignoresSafeArea()
        .onTapGesture {
            isTextFieldFocused = false
        }
        .onAppear {
            withAnimation {
                isTextFieldFocused = true
                hasAppeared = true
            }
        }
        .onDisappear {
            hasAppeared = false
        }
    }
}

// MARK: - Header
struct NameInputHeader: View {
    let title: String
    let hasAppeared: Bool
    let onSkip: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Spacer()
                SkipButton(hasAppeared: hasAppeared, onSkip: onSkip)
            }
            .padding(.top, 80)

            Text(title)
                .font(.system(size: 32, weight: .medium))
                .foregroundColor(AppColors.primaryText)
                .multilineTextAlignment(.center)
                .shadow(color: .black, radius: 1, y: 3)

            Text("Your name is used to personalize your experience")
                .font(AppTypography.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
    }
}

// MARK: - TextField
struct NameTextField: View {
    @Binding var name: String
    var isFocused: FocusState<Bool>.Binding

    var body: some View {
        TextField("Your name", text: $name)
            .focused(isFocused)
            .font(AppTypography.body)
            .foregroundColor(AppColors.primaryText)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.black.opacity(0.3))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isFocused.wrappedValue ? Color.blue : Color.gray.opacity(0.3), lineWidth: 1)
                    )
            )
    }
}



#Preview {
    NameInputView(title: "", onContinue: { }, onSkip: {})

}
