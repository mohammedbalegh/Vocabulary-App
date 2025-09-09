//
//  PagingScrollView.swift
//  Vocabulary
//
//  Created by Mohammed Balegh on 08/09/2025.
//

import SwiftUI

// MARK: - Scroll Configuration
public struct ScrollConfiguration {
    public let cardWidthOffset: CGFloat
    public let cardHeightMultiplier: CGFloat
    public let animationThreshold: CGFloat
    public let maxScale: CGFloat
    public let minScale: CGFloat
    public let maxOpacity: Double
    public let minOpacity: Double
    public let maxRotation: Double
    public let maxBlur: CGFloat
    public let maxOffset: CGFloat
    public let topSpacing: CGFloat
    public let scrollAnimation: Animation
    
    public init(
        cardWidthOffset: CGFloat = 48,
        cardHeightMultiplier: CGFloat = 0.76,
        animationThreshold: CGFloat = 0.3,
        maxScale: CGFloat = 1.0,
        minScale: CGFloat = 0.8,
        maxOpacity: Double = 1.0,
        minOpacity: Double = 0.3,
        maxRotation: Double = 5.0,
        maxBlur: CGFloat = 2.0,
        maxOffset: CGFloat = 20.0,
        topSpacing: CGFloat = 36,
        scrollAnimation: Animation = .spring(response: 0.6, dampingFraction: 0.8)
    ) {
        self.cardWidthOffset = cardWidthOffset
        self.cardHeightMultiplier = cardHeightMultiplier
        self.animationThreshold = animationThreshold
        self.maxScale = maxScale
        self.minScale = minScale
        self.maxOpacity = maxOpacity
        self.minOpacity = minOpacity
        self.maxRotation = maxRotation
        self.maxBlur = maxBlur
        self.maxOffset = maxOffset
        self.topSpacing = topSpacing
        self.scrollAnimation = scrollAnimation
    }
    
    public static let `default` = ScrollConfiguration()
    public static let smooth = ScrollConfiguration(
        scrollAnimation: .spring(response: 0.8, dampingFraction: 0.9)
    )
    public static let snappy = ScrollConfiguration(
        scrollAnimation: .spring(response: 0.4, dampingFraction: 0.7)
    )
}

// MARK: - Animation Data
public struct ScrollAnimationData: Equatable {
    public let scale: CGFloat
    public let opacity: Double
    public let blur: CGFloat
    public let rotation: Angle
    public let offset: CGFloat
    public let parallax: CGFloat
    public let glowIntensity: Double
    
    public init(
        scale: CGFloat,
        opacity: Double,
        blur: CGFloat,
        rotation: Angle,
        offset: CGFloat,
        parallax: CGFloat = 0,
        glowIntensity: Double = 0
    ) {
        self.scale = scale
        self.opacity = opacity
        self.blur = blur
        self.rotation = rotation
        self.offset = offset
        self.parallax = parallax
        self.glowIntensity = glowIntensity
    }
}

// MARK: - Scroll Direction
public enum ScrollDirection {
    case up
    case down
    case none
}

// MARK: - Paging Scroll View
public struct PagingScrollView<Item: Identifiable, Content: View>: View {
    public let items: [Item]
    @Binding public var currentIndex: Int
    public let geometry: GeometryProxy
    public let content: (Int, Item, ScrollAnimationData) -> Content
    public let onScrollToNext: ((Int) -> Void)?
    public let onScrollToPrevious: ((Int) -> Void)?
    public let onScrollDirectionChange: ((ScrollDirection) -> Void)?
    public let configuration: ScrollConfiguration
    
    @State private var scrollPosition: Int?
    @State private var previousIndex: Int = 0
    @State private var scrollDirection: ScrollDirection = .none
    @State private var isScrolling: Bool = false
    @State private var scrollVelocity: CGFloat = 0
    
    public init(
        items: [Item],
        currentIndex: Binding<Int>,
        geometry: GeometryProxy,
        configuration: ScrollConfiguration = .default,
        content: @escaping (Int, Item, ScrollAnimationData) -> Content,
        onScrollToNext: ((Int) -> Void)? = nil,
        onScrollToPrevious: ((Int) -> Void)? = nil,
        onScrollDirectionChange: ((ScrollDirection) -> Void)? = nil
    ) {
        self.items = items
        self._currentIndex = currentIndex
        self.geometry = geometry
        self.configuration = configuration
        self.content = content
        self.onScrollToNext = onScrollToNext
        self.onScrollToPrevious = onScrollToPrevious
        self.onScrollDirectionChange = onScrollDirectionChange
    }
    
    //  animation data calculation
    private func AnimationData(for index: Int) -> ScrollAnimationData {
        let distance = abs(index - currentIndex)
        let progress = max(0, min(1, 1 - CGFloat(distance) * configuration.animationThreshold))
        
        // Calculate dynamic effects with  parameters
        let rotationAngle = distance == 0 ? 0 : Double(distance) * configuration.maxRotation * (index > currentIndex ? 1 : -1)
        let blurAmount = distance == 0 ? 0 : min(configuration.maxBlur, CGFloat(distance) * 0.5)
        let yOffset = distance == 0 ? 0 : sin(CGFloat(distance) * 0.5) * configuration.maxOffset * (index > currentIndex ? 1 : -1)
        
        //  effects
        let parallaxOffset = CGFloat(distance) * 10 * (index > currentIndex ? 1 : -1)
        let glowIntensity = distance == 0 ? 1.0 : max(0, 1.0 - Double(distance) * 0.3)
        
        return ScrollAnimationData(
            scale: configuration.minScale + (configuration.maxScale - configuration.minScale) * progress,
            opacity: configuration.minOpacity + (configuration.maxOpacity - configuration.minOpacity) * Double(progress),
            blur: blurAmount,
            rotation: .degrees(rotationAngle),
            offset: yOffset,
            parallax: parallaxOffset,
            glowIntensity: glowIntensity
        )
    }
    
    // Calculate scroll direction
    private func calculateScrollDirection(from oldIndex: Int, to newIndex: Int) -> ScrollDirection {
        if newIndex > oldIndex {
            return .up
        } else if newIndex < oldIndex {
            return .down
        } else {
            return .none
        }
    }
    
    public var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 0) {
                    ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                        VStack(spacing: 0) {
                            Spacer()
                                .frame(height: configuration.topSpacing)
                            
                            content(index, item, AnimationData(for: index))
                            
                            Spacer()
                        }
                        .frame(
                            width: geometry.size.width - configuration.cardWidthOffset,
                            height: geometry.size.height * configuration.cardHeightMultiplier
                        )
                        .id(index)
                    }
                }
            }
            .scrollTargetLayout()
            .scrollTargetBehavior(.paging)
            .scrollPosition(id: $scrollPosition)
            .onChange(of: scrollPosition) { _, newPosition in
                handleScrollPositionChange(newPosition: newPosition)
            }
            .onChange(of: currentIndex) { _, newIndex in
                handleCurrentIndexChange(newIndex: newIndex, proxy: proxy)
            }
        }
    }
    
    // MARK: - Scroll Handling
    private func handleScrollPositionChange(newPosition: Int?) {
        guard let newPosition = newPosition else { return }
        
        let previousPosition = currentIndex
        let newDirection = calculateScrollDirection(from: previousPosition, to: newPosition)
        
        // Update state
        currentIndex = newPosition
        scrollDirection = newDirection
        isScrolling = true
        
        // Notify direction change
        onScrollDirectionChange?(newDirection)
        
        // Handle scroll callbacks
        switch newDirection {
        case .up:
            onScrollToNext?(previousPosition)
        case .down:
            onScrollToPrevious?(previousPosition)
        case .none:
            break
        }
        
        // Reset scrolling state after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            isScrolling = false
        }
    }
    
    private func handleCurrentIndexChange(newIndex: Int, proxy: ScrollViewProxy) {
        guard scrollPosition != newIndex else { return }
        
        withAnimation(configuration.scrollAnimation) {
            proxy.scrollTo(newIndex, anchor: UnitPoint.top)
        }
    }
}

// MARK: - Convenience Extensions
public extension PagingScrollView {
    /// Create a scroll view with smooth animations
    static func smooth(
        items: [Item],
        currentIndex: Binding<Int>,
        geometry: GeometryProxy,
        content: @escaping (Int, Item, ScrollAnimationData) -> Content,
        onScrollToNext: ((Int) -> Void)? = nil,
        onScrollToPrevious: ((Int) -> Void)? = nil
    ) -> PagingScrollView {
        PagingScrollView(
            items: items,
            currentIndex: currentIndex,
            geometry: geometry,
            configuration: .smooth,
            content: content,
            onScrollToNext: onScrollToNext,
            onScrollToPrevious: onScrollToPrevious
        )
    }
    
    /// Create a scroll view with snappy animations
    static func snappy(
        items: [Item],
        currentIndex: Binding<Int>,
        geometry: GeometryProxy,
        content: @escaping (Int, Item, ScrollAnimationData) -> Content,
        onScrollToNext: ((Int) -> Void)? = nil,
        onScrollToPrevious: ((Int) -> Void)? = nil
    ) -> PagingScrollView {
        PagingScrollView(
            items: items,
            currentIndex: currentIndex,
            geometry: geometry,
            configuration: .snappy,
            content: content,
            onScrollToNext: onScrollToNext,
            onScrollToPrevious: onScrollToPrevious
        )
    }
}
