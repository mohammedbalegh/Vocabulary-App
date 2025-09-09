//
//  HeaderSection.swift
//  Vocabulary
//
//  Created by mohammed balegh on 07/09/2025.
//


import SwiftUI
import Lottie

// MARK: - Header Section
public struct HeaderSection: View {
    public let viewModel: MainViewModel
    public let geometry: GeometryProxy
    public let configuration: MainConfiguration
    
    @State private var isHeaderVisible = false
    
    public var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 8) {
            Spacer()
            
                progressSection
                streakSection
            }
            
            voiceSelectionButton
        }
        .onAppear {
            withAnimation {
                isHeaderVisible = true
            }
        }
    }
    
    private var progressSection: some View {
        ProgressView(
            progress: viewModel.completionPercentage,
            text: viewModel.progressDisplayText,
            configuration: .default,
            animationStyle: .smooth
        )
        .padding(.horizontal, 32)
        .opacity(isHeaderVisible ? 1 : 0)
        .offset(y: isHeaderVisible ? 0 : -20)
        .animation(.easeOut(duration: 0.6).delay(configuration.progressAnimationDelay), value: isHeaderVisible)
    }
    
    private var streakSection: some View {
        VStack(spacing: 4) {
            HStack(spacing: 8) {
                Text("🔥")
                    .font(.system(size: 16))
                Text("\(viewModel.currentStreak)")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                Text("day streak")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            
            Text(viewModel.motivationalMessage)
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .padding(.horizontal, 8)
        }
        .opacity(isHeaderVisible ? 1 : 0)
        .offset(y: isHeaderVisible ? 0 : -20)
        .animation(.easeOut(duration: 0.6).delay(configuration.streakAnimationDelay), value: isHeaderVisible)
    }
    
    private var voiceSelectionButton: some View {
        VoiceSelectionButton(
            currentVoice: viewModel.currentVoice,
            onVoiceChange: { newVoice in
                viewModel.setVoice(newVoice)
            },
            configuration: .compact,
            showHapticFeedback: true
        )
        .padding(.top, 16)
        .padding(.trailing, 16)
        .opacity(isHeaderVisible ? 1 : 0)
        .offset(y: isHeaderVisible ? 0 : -20)
        .animation(.easeOut(duration: 0.6).delay(configuration.voiceButtonAnimationDelay), value: isHeaderVisible)
    }
}
