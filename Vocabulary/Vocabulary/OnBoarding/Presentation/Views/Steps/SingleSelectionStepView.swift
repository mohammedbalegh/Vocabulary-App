//
//  SingleSelectionStepView.swift
//  Vocabulary
//
//  Created by Mohammed Balegh on 06/09/2025.
//

import SwiftUI

struct SingleSelectionStepView<T: OnboardingOption>: View {
    @StateObject private var viewModel: SingleSelectionViewModel<T>
    
    init(
        title: String,
        options: [T],
        initialValue: T?,
        onSelect: @escaping (T) -> Void
    ) {
        self._viewModel = StateObject(
            wrappedValue: SingleSelectionViewModel(
                title: title,
                options: options,
                initialValue: initialValue,
                onSelect: onSelect
            )
        )
    }
    
    var body: some View {
        AnimatedOptionsView(
            title: viewModel.title,
            options: viewModel.options,
            selected: $viewModel.selectedOption
        ) {
            if let selected = viewModel.selectedOption {
                viewModel.selectOption(selected)
            }
        }
    }
}
