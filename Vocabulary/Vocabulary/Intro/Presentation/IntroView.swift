//
//  IntroView.swift
//  Vocabulary
//
//  Created by Mohammed Balegh on 05/09/2025.
//

import SwiftUI
import Lottie

// MARK: - Intro Configuration
public struct IntroViewConfiguration {
    public let lottieAnimationName: String
    public let lottieWidth: CGFloat
    public let lottieHeight: CGFloat
    public let lottieVerticalPadding: CGFloat
    public let animationResponse: Double
    public let animationDamping: Double
    public let initialLottieOffset: CGFloat
    public let cardBottomPadding: CGFloat
    public let transitionDuration: Double
    
    public init(
        lottieAnimationName: String = "Get things done",
        lottieWidth: CGFloat = 400,
        lottieHeight: CGFloat = 350,
        lottieVerticalPadding: CGFloat = 16,
        animationResponse: Double = 0.8,
        animationDamping: Double = 0.6,
        initialLottieOffset: CGFloat = -400,
        cardBottomPadding: CGFloat = 0,
        transitionDuration: Double = 0.5
    ) {
        self.lottieAnimationName = lottieAnimationName
        self.lottieWidth = lottieWidth
        self.lottieHeight = lottieHeight
        self.lottieVerticalPadding = lottieVerticalPadding
        self.animationResponse = animationResponse
        self.animationDamping = animationDamping
        self.initialLottieOffset = initialLottieOffset
        self.cardBottomPadding = cardBottomPadding
        self.transitionDuration = transitionDuration
    }
    
    public static let `default` = IntroViewConfiguration()
    public static let compact = IntroViewConfiguration(
        lottieWidth: 300,
        lottieHeight: 250,
        lottieVerticalPadding: 12
    )
    public static let spacious = IntroViewConfiguration(
        lottieWidth: 500,
        lottieHeight: 400,
        lottieVerticalPadding: 24
    )
}

// MARK: - Intro View
public struct IntroView: View {
    @StateObject private var viewModel: IntroViewModel
    @Binding public var showWalkThrough: Bool
    @State private var hasAppeared = false
    @State private var lottieOffset: CGFloat
    @State private var isTransitioning = false
    
    public let configuration: IntroViewConfiguration
    
    public init(
        showWalkThrough: Binding<Bool>,
        configuration: IntroViewConfiguration = .default,
        dataProvider: IntroDataManager? = nil
    ) {
        self._showWalkThrough = showWalkThrough
        self.configuration = configuration
        self.lottieOffset = configuration.initialLottieOffset
        
        let provider = dataProvider ?? IntroDataRepository()
        self._viewModel = StateObject(wrappedValue: IntroViewModel(dataProvider: provider))
    }
    
    public var body: some View {
        GeometryReader { geometry in
            ZStack {
                backgroundLayer
                contentLayer(geometry: geometry)
            }
            .ignoresSafeArea()
            .onAppear {
                handleViewAppearance()
            }
            .onChange(of: showWalkThrough) { _, newValue in
                handleWalkthroughChange(newValue, geometry: geometry)
            }
        }
    }
    
    // MARK: - View Components
    private var backgroundLayer: some View {
        AppColorPalette.mainBackground
            .ignoresSafeArea()
    }
    
    private func contentLayer(geometry: GeometryProxy) -> some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(height: geometry.safeAreaInsets.top)
            
            lottieAnimationSection
            
            CardView(showWalkthrough: $showWalkThrough)
                .padding(.bottom, geometry.safeAreaInsets.bottom + configuration.cardBottomPadding)
        }
        .offset(y: showWalkThrough ? -geometry.size.height : 0)
        .animation(.easeInOut(duration: configuration.transitionDuration), value: showWalkThrough)
    }
    
    private var lottieAnimationSection: some View {
        LottieView(animation: .named(configuration.lottieAnimationName))
            .configure { lottie in
                lottie.contentMode = .scaleAspectFit
            }
            .playbackMode(.playing(.toProgress(1, loopMode: .loop)))
            .frame(
                width: configuration.lottieWidth,
                height: configuration.lottieHeight
            )
            .padding(.vertical, configuration.lottieVerticalPadding)
            .offset(y: lottieOffset)
            .animation(
                .spring(
                    response: configuration.animationResponse,
                    dampingFraction: configuration.animationDamping,
                    blendDuration: 0
                ),
                value: lottieOffset
            )
            .accessibilityLabel("Introduction animation")
    }
    
    // MARK: - Event Handlers
    private func handleViewAppearance() {
        guard !hasAppeared else { return }
        hasAppeared = true
        
        // Trigger the drop animation when the view appears
        withAnimation {
            lottieOffset = 0
        }
        
        // Start view model animations
        viewModel.startAnimation()
    }
    
    private func handleWalkthroughChange(_ newValue: Bool, geometry: GeometryProxy) {
        isTransitioning = true
        
        // Stop animations when transitioning
        if newValue {
            viewModel.stopAnimation()
        }
        
        // Reset transition state after animation completes
        DispatchQueue.main.asyncAfter(deadline: .now() + configuration.transitionDuration) {
            isTransitioning = false
        }
    }
}

// MARK: - Convenience Extensions
public extension IntroView {
    /// Create a compact intro view
    static func compact(
        showWalkThrough: Binding<Bool>,
        dataProvider: IntroDataManager? = nil
    ) -> IntroView {
        IntroView(
            showWalkThrough: showWalkThrough,
            configuration: .compact,
            dataProvider: dataProvider
        )
    }
    
    /// Create a spacious intro view
    static func spacious(
        showWalkThrough: Binding<Bool>,
        dataProvider: IntroDataManager? = nil
    ) -> IntroView {
        IntroView(
            showWalkThrough: showWalkThrough,
            configuration: .spacious,
            dataProvider: dataProvider
        )
    }
}
