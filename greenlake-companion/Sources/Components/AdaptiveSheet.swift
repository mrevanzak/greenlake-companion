import SwiftUI
import UIKit

// Bridge enum to handle custom detents with value extraction
enum SheetDetent: Hashable {
  case small
  case medium
  case large
  case height(CGFloat)
  case fraction(CGFloat)

  // Convert from PresentationDetent (with value extraction)
  init(from presentationDetent: PresentationDetent) {
    // Use reflection-like approach to extract values
    if presentationDetent == .medium {
      self = .medium
    } else if presentationDetent == .large {
      self = .large
    } else {
      // For custom detents, we need to maintain a mapping
      // This is a limitation we'll work around with a registry
      self = .medium  // fallback
    }
  }

  // Calculate actual height for custom sheet implementation
  // Returns the Y offset from top (larger values = less sheet visible)
  func calculateHeight(in availableHeight: CGFloat) -> CGFloat {
    switch self {
    case .small:
      return availableHeight * 0.7  // Show 30% of sheet
    case .medium:
      return availableHeight * 0.5  // Show 50% of sheet
    case .large:
      return availableHeight * 0.1  // Show 90% of sheet
    case .height(let fixedHeight):
      // Show exactly fixedHeight pixels, constrained between 10% and 90% of available height
      let constrainedHeight = max(availableHeight * 0.1, min(fixedHeight, availableHeight * 0.9))
      return availableHeight - constrainedHeight
    case .fraction(let fraction):
      // Show fraction percentage of sheet (e.g., 0.8 = 80% visible)
      let constrainedFraction = max(0.1, min(fraction, 0.9))
      return availableHeight * (1.0 - constrainedFraction)
    }
  }

  // Sort order for drag gesture handling
  var sortOrder: Int {
    switch self {
    case .small: return 300
    case .medium: return 500
    case .large: return 900
    case .height(let height): return Int(height)
    case .fraction(let fraction): return Int(fraction * 1000)
    }
  }

  // Convert SheetDetent back to PresentationDetent for binding compatibility
  var presentationDetent: PresentationDetent {
    switch self {
    case .small, .medium: return .medium
    case .large: return .large
    case .height(let height): return .height(height)
    case .fraction(let fraction): return .fraction(fraction)
    }
  }
}

// Registry to map PresentationDetent to SheetDetent with value preservation
class DetentRegistry {
  static let shared = DetentRegistry()
  private var mapping: [PresentationDetent: SheetDetent] = [:]

  func register(_ presentationDetent: PresentationDetent, as sheetDetent: SheetDetent) {
    mapping[presentationDetent] = sheetDetent
  }

  func getSheetDetent(for presentationDetent: PresentationDetent) -> SheetDetent {
    return mapping[presentationDetent] ?? SheetDetent(from: presentationDetent)
  }

  func clear() {
    mapping.removeAll()
  }
}

// Enhanced configuration that supports both systems
struct AdaptiveSheetConfiguration {
  var detents: Set<SheetDetent>

  // Auto-sync presentation detents to sheet detents
  init(
    detents: Set<SheetDetent>
  ) {
    self.detents = detents
  }

  var presentationDetents: Set<PresentationDetent> {
    Set(detents.map { $0.presentationDetent })
  }

  static let `default` = AdaptiveSheetConfiguration(detents: [.medium, .large])
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
          .presentationDetents(configuration.presentationDetents)
          .presentationBackgroundInteraction(.enabled)
          .interactiveDismissDisabled()
          .presentationCornerRadius(18)
          .presentationDragIndicator(.visible)
      }
    }
  }
}

struct AdaptiveSheet<SheetContent: View>: ViewModifier {
  @Environment(\.horizontalSizeClass) private var horizontalSizeClass
  @Binding var isPresented: Bool

  @State private var currentDetent: PresentationDetent
  @State private var sheetOffset: CGFloat = 1000
  @State private var isVisible: Bool = false
  @State private var isDismissing: Bool = false

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
    let sortedSheetDetents = Array(configuration.detents).sorted {
      $0.sortOrder < $1.sortOrder
    }
    let firstDetent = sortedSheetDetents.first ?? .medium
    self._currentDetent = State(initialValue: firstDetent.presentationDetent)
  }

  func body(content: Content) -> some View {
    ZStack {
      // your own stuff will go in here!
      content

      if isVisible {
        CustomBottomSheet(
          currentDetent: $currentDetent,
          configuration: configuration,
          content: sheetContent
        )
        .offset(y: sheetOffset)
        .transition(.move(edge: .bottom).combined(with: .opacity))
      }
    }
    .onChange(of: horizontalSizeClass) { old, new in
      handleSizeClassChange(from: old, to: new)
    }
    .onAppear {
      if isPresented {
        isVisible = true
        sheetOffset = 1000
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
          sheetOffset = 0
        }
      } else {
        isVisible = false
        sheetOffset = 1000
      }
    }
    .onChange(of: isPresented) { _, newValue in
      if newValue {
        isVisible = true
        sheetOffset = 1000
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
          sheetOffset = 0
        }
      } else {
        isDismissing = true
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
          sheetOffset = 1000
        }
        let exitDuration = 0.2
        DispatchQueue.main.asyncAfter(deadline: .now() + exitDuration) {
          isVisible = false
          isDismissing = false
        }
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
      let sortedSheetDetents = Array(configuration.detents).sorted {
        $0.sortOrder < $1.sortOrder
      }
      let firstDetent = sortedSheetDetents.first ?? .medium
      currentDetent = isPresented ? .large : firstDetent.presentationDetent
      if isPresented {
        isPresented = false
      }
    }
  }

}

private struct CustomBottomSheet<Content: View>: View {
  @Environment(\.horizontalSizeClass) private var horizontalSizeClass
  @Binding var currentDetent: PresentationDetent

  // we use a dragOffset to apply real-time movement,
  // and update the final position when the drag ends.
  @State private var dragOffset: CGFloat = 0
  @State private var currentSheetDetent: SheetDetent = .medium  // Add this property

  let configuration: AdaptiveSheetConfiguration
  let content: () -> Content

  // Convert presentation detents to sheet detents
  private var sortedSheetDetents: [SheetDetent] {
    Array(configuration.detents).sorted { $0.sortOrder < $1.sortOrder }
  }

  // Initial detent should be the smallest available detent
  private var initialSheetDetent: SheetDetent {
    sortedSheetDetents.first ?? .medium
  }

  var body: some View {
    GeometryReader { geometry in
      VStack(spacing: 0) {
        DragHandle()

        // Content with proper spacing
        content()
          .padding(.horizontal)
          .padding(.top, 8)
      }
      .frame(
        width: horizontalSizeClass == .compact ? geometry.size.width : 400,
        height: geometry.size.height,
        alignment: .top
      )
      .background(
        RoundedRectangle(cornerRadius: 18)
          .fill(.thickMaterial)
      )
      .clipShape(RoundedRectangle(cornerRadius: 18))
      .shadow(
        color: .black.opacity(0.18),
        radius: 14,
        x: 0,
        y: 6
      )
      .offset(
        x: horizontalSizeClass == .compact ? 0 : geometry.size.width * 0.05,
        y: calculatedOffset(for: currentSheetDetent, geometry: geometry) + dragOffset
      )
      // Apply drag gesture to entire sheet for full draggability
      .gesture(
        DragGesture()
          .onChanged { value in
            handleDragChanged(value.translation.height)
          }
          .onEnded { value in
            handleDragEnd(translation: value.translation.height, geometry: geometry)
          }
      )
      .animation(.interactiveSpring(response: 0.4, dampingFraction: 0.8), value: dragOffset)
      .animation(.spring(response: 0.5, dampingFraction: 0.8), value: currentSheetDetent)
      .onChange(of: currentDetent) { oldDetent, newDetent in
        // Convert presentation detent to sheet detent
        currentSheetDetent = DetentRegistry.shared.getSheetDetent(for: newDetent)
      }
    }
    .edgesIgnoringSafeArea(.bottom)
    .onAppear {
      // Initialize with first available detent
      if let firstDetent = sortedSheetDetents.first {
        currentSheetDetent = firstDetent
      }
    }
  }

  // Enhanced drag handling with improved physics and haptic feedback
  private func handleDragChanged(_ translation: CGFloat) {
    // Apply real-time drag with resistance for more natural feel
    let resistance: CGFloat = 0.8
    dragOffset = translation * resistance

    // Add subtle haptic feedback for better user experience
    if abs(translation) > 50 && abs(dragOffset) < 1 {
      let impactFeedback = UIImpactFeedbackGenerator(style: .light)
      impactFeedback.impactOccurred()
    }
  }

  private func handleDragEnd(translation: CGFloat, geometry: GeometryProxy) {
    let threshold: CGFloat = 100

    guard let currentIndex = sortedSheetDetents.firstIndex(of: currentSheetDetent) else { return }

    let newSheetDetent: SheetDetent = {
      if translation > threshold && currentIndex > 0 {
        return sortedSheetDetents[currentIndex - 1]
      }

      if translation < -threshold && currentIndex < sortedSheetDetents.count - 1 {
        return sortedSheetDetents[currentIndex + 1]
      }

      // Find closest detent using actual calculated positions
      let currentY = calculatedOffset(for: currentSheetDetent, geometry: geometry) + dragOffset

      var closestDetent = currentSheetDetent
      var closestDistance = CGFloat.greatestFiniteMagnitude

      for detent in sortedSheetDetents {
        let detentY = calculatedOffset(for: detent, geometry: geometry)
        let distance = abs(currentY - detentY)

        if distance < closestDistance {
          closestDistance = distance
          closestDetent = detent
        }
      }

      return closestDetent
    }()

    withAnimation(.interactiveSpring(response: 0.4, dampingFraction: 0.8)) {
      currentSheetDetent = newSheetDetent
      dragOffset = 0
    }

    // Provide haptic feedback when reaching a new detent
    if newSheetDetent != currentSheetDetent {
      let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
      impactFeedback.impactOccurred()
    }
  }

  // Calculate offset using SheetDetent with proper value extraction
  private func calculatedOffset(for detent: SheetDetent, geometry: GeometryProxy) -> CGFloat {
    let safeAreaHeight = geometry.safeAreaInsets.bottom
    let availableHeight = geometry.size.height - safeAreaHeight

    return detent.calculateHeight(in: availableHeight)
  }

}

private struct DragHandle: View {
  var body: some View {
    Capsule()
      .fill(.quaternary.opacity(0.6))
      .frame(width: 36, height: 5)
      .padding(.top, 12)
      .padding(.bottom, 8)
  }
}
