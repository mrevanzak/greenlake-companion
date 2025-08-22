import SwiftUI
import UIKit

struct AdaptiveSheetConfiguration {
  var detents: Set<PresentationDetent> = [.medium, .large]

  static let `default` = AdaptiveSheetConfiguration()
}

extension View {
  @ViewBuilder
  func adaptiveSheet<Content: View>(
    isPresented: Binding<Bool>,
    configuration: AdaptiveSheetConfiguration = .default,
    @ViewBuilder content: @escaping () -> Content
  ) -> some View {
    if UIDevice.isIPad {
      modifier(
        AdaptiveSheet(
          isPresented: isPresented,
          sheetContent: content,
          configuration: configuration
        ))
    } else {
      self.sheet(isPresented: isPresented) {
        content()
          .presentationDetents(configuration.detents)
          .presentationBackgroundInteraction(.enabled)
          .interactiveDismissDisabled()
      }
    }
  }
}

struct AdaptiveSheet<SheetContent: View>: ViewModifier {
  @Environment(\.horizontalSizeClass) private var horizontalSizeClass
  @Binding var isPresented: Bool

  @State private var currentDetent: PresentationDetent

  let sheetContent: () -> SheetContent
  let configuration: AdaptiveSheetConfiguration

  init(
    isPresented: Binding<Bool>, sheetContent: @escaping () -> SheetContent,
    configuration: AdaptiveSheetConfiguration
  ) {
    self._isPresented = isPresented
    self.sheetContent = sheetContent
    self.configuration = configuration
    // Initialize with the first available detent
    let sortedDetents = Array(configuration.detents).sorted { detent1, detent2 in
      Self.detentSortOrder(detent1) < Self.detentSortOrder(detent2)
    }
    self._currentDetent = State(initialValue: sortedDetents.first ?? .medium)
  }

  func body(content: Content) -> some View {
    ZStack {
      // your own stuff will go in here!
      content

      CustomBottomSheet(
        currentDetent: $currentDetent,
        configuration: configuration,
        content: sheetContent
      )
    }
    .onChange(of: horizontalSizeClass) { old, new in
      handleSizeClassChange(from: old, to: new)
    }
    .onAppear {
      if horizontalSizeClass == .regular {
        isPresented = false
      }
    }
  }

  // device orientation change? fret not :D
  private func handleSizeClassChange(
    from old: UserInterfaceSizeClass?, to new: UserInterfaceSizeClass?
  ) {
    if old == .regular && new == .compact {
      isPresented = (currentDetent == .large)
    }

    if old == .compact && new == .regular {
      let sortedDetents = Array(configuration.detents).sorted { detent1, detent2 in
        Self.detentSortOrder(detent1) < Self.detentSortOrder(detent2)
      }
      currentDetent = isPresented ? .large : (sortedDetents.first ?? .medium)
      isPresented = false
    }
  }

  // Helper method for detent sorting
  private static func detentSortOrder(_ detent: PresentationDetent) -> Int {
    // Since PresentationDetent doesn't expose associated values,
    // we'll use a heuristic approach based on typical usage patterns
    if detent == .medium {
      return 500
    } else if detent == .large {
      return 900
    } else {
      // For custom detents (.height, .fraction, .custom), we assume they are
      // smaller than medium unless they equal large
      // This provides a reasonable default ordering
      return 300
    }
  }
}

private struct CustomBottomSheet<Content: View>: View {
  @Environment(\.horizontalSizeClass) private var horizontalSizeClass
  @Binding var currentDetent: PresentationDetent

  // we use a dragOffset to apply real-time movement,
  // and update the final position when the drag ends.
  @State private var dragOffset: CGFloat = 0

  let configuration: AdaptiveSheetConfiguration
  let content: () -> Content

  // Computed property for sorted detents based on configuration
  private var sortedDetents: [PresentationDetent] {
    Array(configuration.detents).sorted { detent1, detent2 in
      detentSortOrder(detent1) < detentSortOrder(detent2)
    }
  }

  // Initial detent should be the smallest available detent
  private var initialDetent: PresentationDetent {
    sortedDetents.first ?? .medium
  }

  var body: some View {
    GeometryReader { geometry in
      VStack {
        // See 4. for the Handle design :)
        DragHandle { value in
          dragOffset = value
        } onDragEnded: { value in
          handleDragEnd(translation: value, geometry: geometry)
        }

        content()
      }
      .padding(.horizontal)
      .frame(
        width: horizontalSizeClass == .compact ? geometry.size.width : 350,
        height: geometry.size.height,
        alignment: .top
      )
      .background(.white)
      .clipShape(
        .rect(
          topLeadingRadius: 20,
          bottomLeadingRadius: 0,
          bottomTrailingRadius: 0,
          topTrailingRadius: 20
        )
      )
      .shadow(radius: 4)
      .offset(
        x: horizontalSizeClass == .compact ? 0 : geometry.size.width * 0.05,
        y: calculatedOffset(for: currentDetent, geometry: geometry) + dragOffset
      )
      .animation(.interactiveSpring(response: 0.4, dampingFraction: 0.8), value: dragOffset)
    }
    .edgesIgnoringSafeArea(.bottom)
    .onAppear {
      // Set initial detent if current detent is not in available detents
      if !sortedDetents.contains(currentDetent) {
        currentDetent = initialDetent
      }
    }
  }

  // Enhanced drag logic that respects available detent positions
  private func handleDragEnd(translation: CGFloat, geometry: GeometryProxy) {
    let threshold: CGFloat = 100

    // Get current detent index in sorted detents
    guard let currentIndex = sortedDetents.firstIndex(of: currentDetent) else { return }

    let newDetent: PresentationDetent = {
      // Dragging down (positive translation) - move to next smaller detent
      if translation > threshold && currentIndex > 0 {
        return sortedDetents[currentIndex - 1]
      }

      // Dragging up (negative translation) - move to next larger detent
      if translation < -threshold && currentIndex < sortedDetents.count - 1 {
        return sortedDetents[currentIndex + 1]
      }

      // Not enough movement - find closest available detent
      let currentY = calculatedOffset(for: currentDetent, geometry: geometry) + dragOffset

      var closestDetent = currentDetent
      var closestDistance = CGFloat.greatestFiniteMagnitude

      for detent in sortedDetents {
        let detentY = calculatedOffset(for: detent, geometry: geometry)
        let distance = abs(currentY - detentY)

        if distance < closestDistance {
          closestDistance = distance
          closestDetent = detent
        }
      }

      return closestDetent
    }()

    // Animate to new detent with springy feedback
    withAnimation(.interactiveSpring(response: 0.4, dampingFraction: 0.8)) {
      currentDetent = newDetent
      dragOffset = 0
    }
  }

  // Calculate offset for each detent type based on actual values
  private func calculatedOffset(for detent: PresentationDetent, geometry: GeometryProxy) -> CGFloat
  {
    let safeAreaHeight = geometry.safeAreaInsets.bottom
    let availableHeight = geometry.size.height - safeAreaHeight

    // Since PresentationDetent doesn't expose associated values for pattern matching,
    // we use equality comparison and provide reasonable defaults
    if detent == .medium {
      // Medium is typically ~50% of available height
      return availableHeight * 0.5
    } else if detent == .large {
      // Large shows most content, ~10% from top
      return availableHeight * 0.1
    } else {
      // For custom detents (.height, .fraction, .custom), we need to make
      // reasonable assumptions since we can't extract their values
      // Try to evaluate if it's a custom detent, otherwise use medium as fallback
      if let customHeight = evaluateCustomDetent(detent, geometry: geometry) {
        return availableHeight - customHeight
      }
      // Fallback to a smaller size than medium for custom detents
      return availableHeight * 0.7
    }
  }

  // Evaluate custom detents in current context
  private func evaluateCustomDetent(_ detent: PresentationDetent, geometry: GeometryProxy)
    -> CGFloat?
  {
    // Note: PresentationDetent doesn't expose custom detent evaluation directly
    // This would require additional API or approximation based on typical custom detent patterns
    // For now, return nil to use fallback behavior
    return nil
  }

  // Determine sort order for detents
  private func detentSortOrder(_ detent: PresentationDetent) -> Int {
    // Since PresentationDetent doesn't expose associated values,
    // we'll use a heuristic approach based on typical usage patterns
    if detent == .medium {
      return 500
    } else if detent == .large {
      return 900
    } else {
      // For custom detents (.height, .fraction, .custom), we assume they are
      // smaller than medium unless they equal large
      // This provides a reasonable default ordering
      return 300
    }
  }
}

private struct DragHandle: View {
  let onDragChanged: (CGFloat) -> Void
  let onDragEnded: (CGFloat) -> Void

  var body: some View {
    // where the design goes
    Capsule()
      .frame(width: 40, height: 6)
      .foregroundColor(.gray)
      .padding(10)
      .contentShape(Rectangle())
      .gesture(
        // actual gesture handling
        DragGesture()
          .onChanged { value in onDragChanged(value.translation.height) }
          .onEnded { value in onDragEnded(value.translation.height) }
      )
  }
}
