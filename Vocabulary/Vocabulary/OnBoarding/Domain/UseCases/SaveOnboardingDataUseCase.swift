//
//  SaveOnboardingDataUseCase.swift
//  Vocabulary
//
//  Created by Mohammed Balegh on 06/09/2025.
//

import Foundation
import Combine

public protocol SaveOnboardingDataUseCaseProtocol {
    func execute(_ data: OnboardingData) -> AnyPublisher<Void, Error>
}

final class SaveOnboardingDataUseCase: SaveOnboardingDataUseCaseProtocol {
    private let repository: OnboardingRepositoryProtocol
    
    init(repository: OnboardingRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(_ data: OnboardingData) -> AnyPublisher<Void, Error> {
        var updatedData = data
        
        // Mark as completed when saving at the done step
        if updatedData.completedAt == nil && hasAllRequiredData(updatedData) {
            updatedData.completedAt = Date()
        }
        
        return Future { [self] promise in
            Task {
                do {
                    try await repository.save(updatedData)
                    promise(.success(()))
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    private func hasAllRequiredData(_ data: OnboardingData) -> Bool {
        // Check if all required fields are filled
        // Name, goals, and topics are optional (can be skipped)
        return data.referral != nil &&
               data.ageRange != nil &&
               data.gender != nil
    }
}
