//
//  NameInputStepView.swift
//  Vocabulary
//
//  Created by Mohammed Balegh on 06/09/2025.
//


import SwiftUI

struct NameInputStepView: View {
    @StateObject var viewModel: NameInputViewModel
    @FocusState private var isTextFieldFocused: Bool
    @State private var hasAppeared = false
    
    var body: some View {
        ScrollView {
            VStack {
                // Header
                VStack(spacing: 16) {
                    Spacer()
                        .frame(height: 80)
                    
                    Text(viewModel.title)
                        .font(.system(size: 32, weight: .medium))
                        .foregroundColor(AppColors.primaryText)
                        .multilineTextAlignment(.center)
                        .shadow(color: .black, radius: 1, y: 3)
                    
                    Text(viewModel.subtitle)
                        .font(AppTypography.body)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                .padding(.horizontal, 20)
                .opacity(hasAppeared ? 1 : 0)
                .offset(y: hasAppeared ? 0 : -20)
                .animation(AppAnimations.headerSpring, value: hasAppeared)
                
                // Text Field
                VStack(spacing: 24) {
                    ZStack(alignment: .leading) {
                        if viewModel.name.isEmpty {
                            Text("Your name")
                                .font(AppTypography.body)
                                .foregroundColor(Color.white.opacity(0.3))
                                .padding()
                        }

                        TextField("", text: $viewModel.name)
                            .focused($isTextFieldFocused)
                            .font(AppTypography.body)
                            .foregroundColor(AppColors.primaryText)
                            .padding()
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.black.opacity(0.3))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(
                                        isTextFieldFocused ? Color.blue : Color.gray.opacity(0.3),
                                        lineWidth: 1
                                    )
                            )
                    )
                    .opacity(hasAppeared ? 1 : 0)
                    .offset(y: hasAppeared ? 0 : 20)
                    .animation(
                        AppAnimations.defaultEaseOut.delay(0.3),
                        value: hasAppeared
                    )
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)
                .padding(.bottom, 60)
                
                
                // Continue Button
                ContinueButton(
                    isEnabled: viewModel.canContinue,
                    hasAppeared: hasAppeared,
                    delay: 0.6,
                    onTap: viewModel.continueAction
                )
                .disabled(viewModel.isProcessing)
                
            }
        }
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
