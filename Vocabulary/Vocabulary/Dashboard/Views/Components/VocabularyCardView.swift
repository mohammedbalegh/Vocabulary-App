//
//  VocabularyCardView.swift
//  Vocabulary
//
//  Created by Mohammed Balegh on 08/09/2025.
//

import SwiftUI
import Lottie

// MARK: - Card Configuration
public struct VocabularyCardConfiguration {
    public let cornerRadius: CGFloat
    public let shadowRadius: CGFloat
    public let shadowOffset: CGPoint
    public let animationSize: CGSize
    public let contentPadding: CGFloat
    public let verticalSpacing: CGFloat
    public let wordFontSize: CGFloat
    public let pronunciationFontSize: CGFloat
    public let definitionFontSize: CGFloat
    public let exampleFontSize: CGFloat
    public let successTitleFontSize: CGFloat
    public let successSubtitleFontSize: CGFloat
    public let keepLearningTitleFontSize: CGFloat
    public let keepLearningSubtitleFontSize: CGFloat
    
    public init(
        cornerRadius: CGFloat = 25,
        shadowRadius: CGFloat = 20,
        shadowOffset: CGPoint = CGPoint(x: 0, y: 10),
        animationSize: CGSize = CGSize(width: 200, height: 200),
        contentPadding: CGFloat = 24,
        verticalSpacing: CGFloat = 32,
        wordFontSize: CGFloat = 56,
        pronunciationFontSize: CGFloat = 16,
        definitionFontSize: CGFloat = 20,
        exampleFontSize: CGFloat = 18,
        successTitleFontSize: CGFloat = 24,
        successSubtitleFontSize: CGFloat = 18,
        keepLearningTitleFontSize: CGFloat = 32,
        keepLearningSubtitleFontSize: CGFloat = 18
    ) {
        self.cornerRadius = cornerRadius
        self.shadowRadius = shadowRadius
        self.shadowOffset = shadowOffset
        self.animationSize = animationSize
        self.contentPadding = contentPadding
        self.verticalSpacing = verticalSpacing
        self.wordFontSize = wordFontSize
        self.pronunciationFontSize = pronunciationFontSize
        self.definitionFontSize = definitionFontSize
        self.exampleFontSize = exampleFontSize
        self.successTitleFontSize = successTitleFontSize
        self.successSubtitleFontSize = successSubtitleFontSize
        self.keepLearningTitleFontSize = keepLearningTitleFontSize
        self.keepLearningSubtitleFontSize = keepLearningSubtitleFontSize
    }
    
    public static let `default` = VocabularyCardConfiguration()
    public static let compact = VocabularyCardConfiguration(
        cornerRadius: 12,
        contentPadding: 16,
        verticalSpacing: 20,
        wordFontSize: 40,
        definitionFontSize: 16,
        exampleFontSize: 14
    )
    public static let prominent = VocabularyCardConfiguration(
        cornerRadius: 30,
        shadowRadius: 25,
        contentPadding: 32,
        verticalSpacing: 40,
        wordFontSize: 64,
        definitionFontSize: 24,
        exampleFontSize: 20
    )
}

// MARK: - Card Type
public enum VocabularyCardType {
    case vocabulary
    case success
    case keepLearning
}

// MARK: - Vocabulary Card View
public struct VocabularyCardView: View {
    public let vocabulary: VocabularyWord
    public let onPronunciationTap: () -> Void
    public let totalCompleted: Int
    public let animationData: ScrollAnimationData
    public let isPlayingSpeech: Bool
    public let onSuccessCardVisible: (() -> Void)?
    public let onRecordLearningActivity: (() -> Void)?
    public let configuration: VocabularyCardConfiguration
    
    @State private var isAnimating: Bool = false
    @State private var glowIntensity: Double = 0.0
    
    public init(
        vocabulary: VocabularyWord,
        onPronunciationTap: @escaping () -> Void,
        totalCompleted: Int,
        animationData: ScrollAnimationData,
        isPlayingSpeech: Bool,
        configuration: VocabularyCardConfiguration = .default,
        onSuccessCardVisible: (() -> Void)? = nil,
        onRecordLearningActivity: (() -> Void)? = nil
    ) {
        self.vocabulary = vocabulary
        self.onPronunciationTap = onPronunciationTap
        self.totalCompleted = totalCompleted
        self.animationData = animationData
        self.isPlayingSpeech = isPlayingSpeech
        self.configuration = configuration
        self.onSuccessCardVisible = onSuccessCardVisible
        self.onRecordLearningActivity = onRecordLearningActivity
    }
    
    private var cardType: VocabularyCardType {
        if vocabulary.word == "SUCCESS" {
            return totalCompleted == 5 ? .success : .keepLearning
        }
        return .vocabulary
    }
    
    public var body: some View {
        cardContent
            .cardStyle(configuration: configuration)
            .applyScrollAnimations(animationData)
            .onAppear {
                startGlowAnimation()
            }
    }
    
    @ViewBuilder
    private var cardContent: some View {
        VStack(spacing: configuration.verticalSpacing) {
            Group {
                switch cardType {
                case .vocabulary:
                    VocabularyContentView(
                        vocabulary: vocabulary,
                        onPronunciationTap: onPronunciationTap,
                        isPlayingSpeech: isPlayingSpeech,
                        configuration: configuration
                    )
                case .success:
                    SuccessAnimationView(
                        vocabulary: vocabulary,
                        configuration: configuration,
                        onAppear: {
                            onSuccessCardVisible?()
                            onRecordLearningActivity?()
                        }
                    )
                case .keepLearning:
                    KeepLearningView(
                        totalCompleted: totalCompleted,
                        configuration: configuration
                    )
                }
            }
        }
        .padding(configuration.contentPadding)
        Spacer()
    }
    
    private func startGlowAnimation() {
        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
            glowIntensity = 1.0
        }
    }
}

// MARK: - Vocabulary Content View
public struct VocabularyContentView: View {
    public let vocabulary: VocabularyWord
    public let onPronunciationTap: () -> Void
    public let isPlayingSpeech: Bool
    public let configuration: VocabularyCardConfiguration
    
    public var body: some View {
        VStack(spacing: configuration.verticalSpacing) {
            WordSection(
                vocabulary: vocabulary,
                onPronunciationTap: onPronunciationTap,
                isPlayingSpeech: isPlayingSpeech,
                configuration: configuration
            )
            DefinitionSection(
                vocabulary: vocabulary,
                configuration: configuration
            )
        }
    }
}

// MARK: - Word Section
public struct WordSection: View {
    public let vocabulary: VocabularyWord
    public let onPronunciationTap: () -> Void
    public let isPlayingSpeech: Bool
    public let configuration: VocabularyCardConfiguration
    
    public var body: some View {
        VStack(spacing: 12) {
            Text(vocabulary.word)
                .font(.system(size: configuration.wordFontSize, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .minimumScaleFactor(0.7)
                .lineLimit(1)
                .accessibilityLabel("Word: \(vocabulary.word)")
            
            PronunciationButton(
                pronunciation: vocabulary.pronunciation,
                isPlayingSpeech: isPlayingSpeech,
                onTap: onPronunciationTap,
                configuration: configuration
            )
        }
    }
}

// MARK: - Pronunciation Button
public struct PronunciationButton: View {
    public let pronunciation: String
    public let isPlayingSpeech: Bool
    public let onTap: () -> Void
    public let configuration: VocabularyCardConfiguration
    
    @State private var isPressed: Bool = false
    
    public var body: some View {
        Button(action: onTap) {
            HStack(spacing: 8) {
                Text(pronunciation)
                    .font(.system(size: configuration.pronunciationFontSize, weight: .medium))
                    .foregroundColor(.gray)
                
                Image(systemName: isPlayingSpeech ? "mouth.fill" : "speaker.2.fill")
                    .foregroundColor(.gray)
                    .font(.system(size: configuration.pronunciationFontSize))
                    .animation(.easeInOut(duration: 0.2), value: isPlayingSpeech)
            }
        }
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
        .accessibilityLabel("Pronunciation: \(pronunciation)")
        .accessibilityHint("Tap to hear pronunciation")
    }
}

// MARK: - Definition Section
public struct DefinitionSection: View {
    public let vocabulary: VocabularyWord
    public let configuration: VocabularyCardConfiguration
    
    public var body: some View {
        VStack(spacing: 16) {
            Text("(\(vocabulary.partOfSpeech)) \(vocabulary.definition)")
                .font(.system(size: configuration.definitionFontSize, weight: .medium))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineLimit(nil)
                .accessibilityLabel("Definition: \(vocabulary.partOfSpeech) \(vocabulary.definition)")
            
            Text(vocabulary.example)
                .font(.system(size: configuration.exampleFontSize))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .lineLimit(nil)
                .italic()
                .accessibilityLabel("Example: \(vocabulary.example)")
        }
    }
}

// MARK: - Success Animation View
public struct SuccessAnimationView: View {
    public let vocabulary: VocabularyWord
    public let configuration: VocabularyCardConfiguration
    public let onAppear: () -> Void
    
    public var body: some View {
        VStack(spacing: 24) {
            LottieView(animation: .named("finished.json"))
                .configure { lottie in
                    lottie.contentMode = .scaleAspectFit
                }
                .playbackMode(.playing(.toProgress(1, loopMode: .loop)))
                .frame(
                    width: configuration.animationSize.width,
                    height: configuration.animationSize.height
                )
                .accessibilityLabel("Success animation")
            
            SuccessTextView(
                vocabulary: vocabulary,
                configuration: configuration
            )
        }
        .onAppear {
            onAppear()
        }
    }
}

// MARK: - Success Text View
public struct SuccessTextView: View {
    public let vocabulary: VocabularyWord
    public let configuration: VocabularyCardConfiguration
    
    public var body: some View {
        VStack(spacing: 16) {
            Text(vocabulary.definition)
                .font(.system(size: configuration.successTitleFontSize, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 16)
                .accessibilityLabel("Success message: \(vocabulary.definition)")
            
            Text(vocabulary.example)
                .font(.system(size: configuration.successSubtitleFontSize))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 20)
                .accessibilityLabel("Success subtitle: \(vocabulary.example)")
        }
    }
}

// MARK: - Keep Learning View
public struct KeepLearningView: View {
    public let totalCompleted: Int
    public let configuration: VocabularyCardConfiguration
    
    public var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 16) {
                Text("Keep Learning!")
                    .font(.system(size: configuration.keepLearningTitleFontSize, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .accessibilityLabel("Keep Learning")
                
                Text("Complete all \(5 - totalCompleted) remaining cards to unlock your success celebration!")
                    .font(.system(size: configuration.keepLearningSubtitleFontSize))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .accessibilityLabel("Complete \(5 - totalCompleted) remaining cards to unlock success celebration")
            }
        }
    }
}

// MARK: - View Extensions
public extension View {
    func cardStyle(configuration: VocabularyCardConfiguration) -> some View {
        self
            .background {
                RoundedRectangle(cornerRadius: configuration.cornerRadius)
                    .fill(AppColorPalette.cardBackground)
            }
            .shadow(
                color: Color.black.opacity(0.25),
                radius: configuration.shadowRadius,
                x: configuration.shadowOffset.x,
                y: configuration.shadowOffset.y
            )
            .frame(maxWidth: .infinity)
    }
    
    func applyScrollAnimations(_ data: ScrollAnimationData) -> some View {
        self
            .scaleEffect(data.scale)
            .opacity(data.opacity)
            .blur(radius: data.blur)
            .rotation3DEffect(
                data.rotation,
                axis: (x: 0.0, y: 0.0, z: 1.0),
                perspective: 0.5
            )
            .offset(y: data.offset)
            .offset(x: data.parallax)
            .shadow(
                color: Color.white.opacity(data.glowIntensity * 0.3),
                radius: 10 * data.glowIntensity,
                x: 0,
                y: 0
            )
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: data)
    }
}

// MARK: - Convenience Extensions
public extension VocabularyCardView {
    /// Create a compact vocabulary card
    static func compact(
        vocabulary: VocabularyWord,
        onPronunciationTap: @escaping () -> Void,
        totalCompleted: Int,
        animationData: ScrollAnimationData,
        isPlayingSpeech: Bool,
        onSuccessCardVisible: (() -> Void)? = nil,
        onRecordLearningActivity: (() -> Void)? = nil
    ) -> VocabularyCardView {
        VocabularyCardView(
            vocabulary: vocabulary,
            onPronunciationTap: onPronunciationTap,
            totalCompleted: totalCompleted,
            animationData: animationData,
            isPlayingSpeech: isPlayingSpeech,
            configuration: .compact,
            onSuccessCardVisible: onSuccessCardVisible,
            onRecordLearningActivity: onRecordLearningActivity
        )
    }
    
    /// Create a prominent vocabulary card
    static func prominent(
        vocabulary: VocabularyWord,
        onPronunciationTap: @escaping () -> Void,
        totalCompleted: Int,
        animationData: ScrollAnimationData,
        isPlayingSpeech: Bool,
        onSuccessCardVisible: (() -> Void)? = nil,
        onRecordLearningActivity: (() -> Void)? = nil
    ) -> VocabularyCardView {
        VocabularyCardView(
            vocabulary: vocabulary,
            onPronunciationTap: onPronunciationTap,
            totalCompleted: totalCompleted,
            animationData: animationData,
            isPlayingSpeech: isPlayingSpeech,
            configuration: .prominent,
            onSuccessCardVisible: onSuccessCardVisible,
            onRecordLearningActivity: onRecordLearningActivity
        )
    }
}
