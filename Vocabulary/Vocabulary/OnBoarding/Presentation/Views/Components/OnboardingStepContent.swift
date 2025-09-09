//
//  OnboardingStepContent.swift
//  Vocabulary
//
//  Created by Mohammed Balegh on 06/09/2025.
//

import SwiftUI

struct OnboardingStepContent: View {
    let activeStep: OnboardingStep
    let onboardingData: OnboardingData
    let onUpdateUserReferral: (Referral) -> Void
    let onUpdateUserAge: (AgeRange) -> Void
    let onUpdateUserGender: (GenderOptions) -> Void
    let onUpdateUserName: (String) -> Void
    let onUpdateUserGoals: (Set<GoalsOptions>) -> Void
    let onUpdateUserTopics: (Set<TopicsOptions>) -> Void
    let onAdvanceToNextStep: () -> Void
    let onSkipCurrentStep: () -> Void
    
    var body: some View {
        switch activeStep {
        case .referral:
            SingleSelectionStepView(
                title: activeStep.title,
                options: Referral.allCases,
                initialValue: onboardingData.referral,
                onSelect: { referral in
                    onUpdateUserReferral(referral)
                    onAdvanceToNextStep()
                }
            )

        case .tailor:
            TailorStepView(
                title: activeStep.title,
                animationName: activeStep.animationName!,
                onContinue: {
                    onAdvanceToNextStep()
                }
            )

        case .age:
            SingleSelectionStepView(
                title: activeStep.title,
                options: AgeRange.allCases,
                initialValue: onboardingData.ageRange,
                onSelect: { age in
                    onUpdateUserAge(age)
                    onAdvanceToNextStep()
                }
            )
            
        case .gender:
            SingleSelectionStepView(
                title: activeStep.title,
                options: GenderOptions.allCases,
                initialValue: onboardingData.gender,
                onSelect: { gender in
                    onUpdateUserGender(gender)
                    onAdvanceToNextStep()
                }
            )
            
        case .nameInput:
            NameInputStepView(
                viewModel: NameInputViewModel(
                    initialValue: onboardingData.name,
                    onContinue: { name in
                        onUpdateUserName(name)
                        onAdvanceToNextStep()
                    },
                    onSkip: {
                        onSkipCurrentStep()
                    }
                )
            )
            
        case .goals:
            GoalsStepView(
                viewModel: MultiSelectionViewModel(
                    title: activeStep.title,
                    options: GoalsOptions.allCases,
                    initialValues: onboardingData.goals,
                    onContinue: { goals in
                        onUpdateUserGoals(goals)
                        onAdvanceToNextStep()
                    },
                    onSkip: {
                        onSkipCurrentStep()
                    }
                )
            )
            
        case .topics:
            TopicsStepView(
                viewModel: MultiSelectionViewModel(
                    title: activeStep.title,
                    options: TopicsOptions.allCases,
                    initialValues: onboardingData.topics,
                    onContinue: { topics in
                        onUpdateUserTopics(topics)
                        onAdvanceToNextStep()
                    },
                    onSkip: {
                        onSkipCurrentStep()
                    }
                )
            )
            .transition(.opacity)
            
        case .done:
            TailorStepView(
                title: activeStep.title,
                animationName: activeStep.animationName!,
                onContinue: {
                    onAdvanceToNextStep()
                }
            )
        }
    }
}
