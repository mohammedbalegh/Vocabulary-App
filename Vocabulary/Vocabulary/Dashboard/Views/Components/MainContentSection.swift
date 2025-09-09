//
//  MainContentSection.swift
//  Vocabulary
//
//  Created by mohammed balegh on 07/09/2025.
//

import SwiftUI

// MARK: - Main Content Section
public struct MainContentSection: View {
    public let viewModel: MainViewModel
    public let geometry: GeometryProxy
    public let configuration: MainConfiguration
    
    public var body: some View {
        if !viewModel.vocabularyList.isEmpty {
            PagingScrollView(
                items: viewModel.vocabularyList,
                    currentIndex: Binding(
                    get: { viewModel.activeIndex },
                    set: { newIndex in
                        viewModel.activeIndex = newIndex
                    }
                ),
                geometry: geometry,
                configuration: .smooth,
                content: { index, vocabulary, animationData in
                    VocabularyCardView(
                        vocabulary: vocabulary,
                        onPronunciationTap: { viewModel.playWordPronunciation() },
                        totalCompleted: viewModel.completionCount,
                        animationData: animationData,
                        isPlayingSpeech: viewModel.isPlayingSpeech,
                        configuration: .default,
                        onSuccessCardVisible: {
                            viewModel.provideSuccessFeedback()
                        },
                        onRecordLearningActivity: {
                            viewModel.recordLearningActivity()
                        }
                    )
                    .id(viewModel.isPlayingSpeech)
                },
                onScrollToNext: { index in
                    viewModel.markWordAsLearned(at: index)
                },
                onScrollToPrevious: { index in
                    viewModel.markWordAsUnlearned(at: index)
                }
            )
        }
    }
}
