//
//  MultiSelectionViewModel.swift
//  Vocabulary
//
//  Created by Mohammed Balegh on 06/09/2025.
//

import Foundation
import Combine

@MainActor
final class MultiSelectionViewModel<T: OnboardingOption>: ObservableObject {
    @Published var selectedOptions: Set<T> = []
    @Published private(set) var isProcessing = false
    
    let title: String
    let options: [T]
    let allowsSkip: Bool
    
    private let onContinue: (Set<T>) -> Void
    private let onSkip: () -> Void
    
    init(
        title: String,
        options: [T],
        initialValues: Set<T> = [],
        allowsSkip: Bool = true,
        onContinue: @escaping (Set<T>) -> Void,
        onSkip: @escaping () -> Void
    ) {
        self.title = title
        self.options = options
        self.selectedOptions = initialValues
        self.allowsSkip = allowsSkip
        self.onContinue = onContinue
        self.onSkip = onSkip
    }
    
    func toggleOption(_ option: T) {
        if selectedOptions.contains(option) {
            selectedOptions.remove(option)
        } else {
            selectedOptions.insert(option)
        }
    }
    
    func continueAction() {
        isProcessing = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            guard let self else { return }
            self.isProcessing = false
            self.onContinue(self.selectedOptions)
        }
    }
    
    func skipAction() {
        onSkip()
    }
    
    var canContinue: Bool {
        !selectedOptions.isEmpty
    }
}
