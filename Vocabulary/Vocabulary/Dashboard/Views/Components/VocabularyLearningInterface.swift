//
//  VocabularyLearningInterface.swift
//  Vocabulary
//
//  Created by mohammed balegh on 07/09/2025.
//

import SwiftUI

// MARK: - Vocabulary Learning Interface
public struct VocabularyLearningInterface: View {
    public let viewModel: MainViewModel
    public let geometry: GeometryProxy
    public let configuration: MainConfiguration
    
    public var body: some View {
        VStack(spacing: 12) {
            HeaderSection(
                viewModel: viewModel,
                geometry: geometry,
                configuration: configuration
            )
            .frame(height: geometry.size.height * configuration.headerHeightMultiplier)
            
            MainContentSection(
                viewModel: viewModel,
                geometry: geometry,
                configuration: configuration
            )
            .frame(height: geometry.size.height * configuration.mainContentHeightMultiplier)
        }
    }
}
