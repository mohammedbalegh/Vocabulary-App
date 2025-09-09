//
//  NameInputViewModel.swift
//  Vocabulary
//
//  Created by Mohammed Balegh on 06/09/2025.
//

import Foundation
import Combine

@MainActor
final class NameInputViewModel: ObservableObject {
    @Published var name: String = ""
    @Published private(set) var isProcessing = false
    
    let title = OnboardingStep.nameInput.title
    let subtitle = "Your name is used to personalize your experience"
    
    private let onContinue: (String) -> Void
    private let onSkip: () -> Void
    
    init(
        initialValue: String? = nil,
        onContinue: @escaping (String) -> Void,
        onSkip: @escaping () -> Void
    ) {
        self.name = initialValue ?? ""
        self.onContinue = onContinue
        self.onSkip = onSkip
    }
    
    var canContinue: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    func continueAction() {
        guard canContinue else { return }
        
        isProcessing = true
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.isProcessing = false
            self?.onContinue(trimmedName)
        }
    }
    
    func skipAction() {
        onSkip()
    }
}
