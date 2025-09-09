//
//  SingleSelectionViewModel.swift
//  Vocabulary
//
//  Created by Mohammed Balegh on 06/09/2025.
//

import Foundation
import Combine

@MainActor
final class SingleSelectionViewModel<T: OnboardingOption>: ObservableObject {
    @Published var selectedOption: T?
    
    let title: String
    let options: [T]
    
    private let onSelect: (T) -> Void
    
    init(
        title: String,
        options: [T],
        initialValue: T? = nil,
        onSelect: @escaping (T) -> Void
    ) {
        self.title = title
        self.options = options
        self.selectedOption = initialValue
        self.onSelect = onSelect
    }
    
    func selectOption(_ option: T) {
        selectedOption = option
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.onSelect(option)
        }
    }
}
