import SwiftUI
import UIKit

enum SheetConstants {
  static let width: CGFloat = 400
}

// Bridge enum to handle custom detents with value extraction
enum SheetDetent: Hashable {
  case small
  case medium
  case large
  case height(CGFloat)
  case fraction(CGFloat)

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

// Enhanced configuration that supports both systems
struct AdaptiveSheetConfiguration {
  var detents: Set<SheetDetent>
  var dismissThreshold: CGFloat = 150
  var detentHopThreshold: CGFloat = 100
  var onDragging: ((CGFloat) -> Void)? = nil
  var onDismiss: (() -> Void)? = nil

  var presentationDetents: Set<PresentationDetent> {
    Set(detents.map { $0.presentationDetent })
  }

  var sortedDetents: [SheetDetent] {
    Array(detents).sorted { $0.sortOrder < $1.sortOrder }
  }

  var firstDetent: SheetDetent {
    sortedDetents.first ?? .medium
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
          .padding()
          .presentationDetents(configuration.presentationDetents)
          .presentationBackgroundInteraction(.enabled)
          .interactiveDismissDisabled()
          .presentationCornerRadius(20)
          .presentationDragIndicator(.visible)
      }
    }
  }
}

struct AdaptiveSheet<SheetContent: View>: ViewModifier {
  @Environment(\.horizontalSizeClass) private var horizontalSizeClass
  @Binding var isPresented: Bool

  @State private var sheetOffset: CGFloat = 1000
  @State private var isVisible: Bool = false
  @State private var isDismissing: Bool = false
  @State private var sheetViewModel: SheetViewModel

  let sheetContent: () -> SheetContent
  let configuration: AdaptiveSheetConfiguration

  private func requestDismiss() {
    configuration.onDismiss?()
    isPresented = false
  }

  init(
    isPresented: Binding<Bool>,
    sheetContent: @escaping () -> SheetContent,
    configuration: AdaptiveSheetConfiguration
  ) {
    self._isPresented = isPresented
    self.sheetContent = sheetContent
    self.configuration = configuration

    let firstDetent = configuration.firstDetent
    self._sheetViewModel = State(
      initialValue: SheetViewModel(detents: configuration.detents, initialDetent: firstDetent)
    )
  }

  func body(content: Content) -> some View {
    ZStack {
      content

      if isVisible {
        CustomBottomSheet(
          sheetViewModel: sheetViewModel,
          configuration: configuration,
          onRequestDismiss: requestDismiss,
          content: sheetContent
        )
        .offset(y: sheetOffset)
        .transition(.move(edge: .bottom).combined(with: .opacity))
      }
    }
    .onChange(of: horizontalSizeClass) { _, new in
      handleSizeClassChange(to: new)
    }
    .onAppear {
      updateSheetVisibility()
    }
    .onChange(of: isPresented) { _, newValue in
      updateSheetVisibility()
    }
  }

  // MARK: - Private Methods

  private func updateSheetVisibility() {
    if isPresented {
      showSheet()
    } else {
      hideSheet()
    }
  }

  private func showSheet() {
    isVisible = true
    sheetOffset = 1000
    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
      sheetOffset = 0
    }
  }

  private func hideSheet() {
    isDismissing = true
    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
      sheetOffset = 1000
    }

    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
      isVisible = false
      isDismissing = false
    }
  }

  private func handleSizeClassChange(to new: UserInterfaceSizeClass?) {
    guard let new = new else { return }

    if new == .compact {
      isPresented = (sheetViewModel.currentDetent == .large)
    } else {
      sheetViewModel.currentDetent = isPresented ? .large : configuration.firstDetent
      if isPresented {
        isPresented = false
      }
    }
  }
}

private struct CustomBottomSheet<Content: View>: View {
  @Environment(\.horizontalSizeClass) private var horizontalSizeClass
  @ObservedObject var sheetViewModel: SheetViewModel

  @State private var dragOffset: CGFloat = 0

  let configuration: AdaptiveSheetConfiguration
  let onRequestDismiss: () -> Void
  let content: () -> Content

  init(
    sheetViewModel: SheetViewModel,
    configuration: AdaptiveSheetConfiguration,
    onRequestDismiss: @escaping () -> Void,
    content: @escaping () -> Content
  ) {
    self.sheetViewModel = sheetViewModel
    self.configuration = configuration
    self.onRequestDismiss = onRequestDismiss
    self.content = content
  }

  var body: some View {
    GeometryReader { geometry in
      ZStack(alignment: .top) {
        NavigationStack {
          content()
            .scrollDisabled(sheetViewModel.isSmallest)
            .environmentObject(sheetViewModel)
            //          .padding(.horizontal)
            .padding(.top, 0)
        }

        DragHandle()
      }
      .frame(
        width: horizontalSizeClass == .compact ? geometry.size.width : SheetConstants.width,
        height: geometry.size.height,
        alignment: .top
      )
      .background(Color(.systemBackground))
      .clipShape(RoundedRectangle(cornerRadius: 20))
      .shadow(
        color: .black.opacity(0.2),
        radius: 8,
        x: 0,
        y: 6
      )
      .offset(
        x: horizontalSizeClass == .compact ? 0 : 24,
        y: calculatedOffset(for: sheetViewModel.currentDetent, geometry: geometry) + dragOffset
      )
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
      .animation(
        .spring(response: 0.5, dampingFraction: 0.8), value: sheetViewModel.currentDetent
      )
      .onChange(of: sheetViewModel.currentDetent) { _, newDetent in
        sheetViewModel.currentDetent = newDetent
        sheetViewModel.updateCurrentDetent(newDetent)
      }
    }
//    .edgesIgnoringSafeArea(.bottom)
    .onAppear {
      let firstDetent = configuration.firstDetent
      sheetViewModel.currentDetent = firstDetent
      sheetViewModel.updateCurrentDetent(firstDetent)
    }
  }

  // MARK: - Private Methods

  private func handleDragChanged(_ translation: CGFloat) {
    let resistance: CGFloat = 0.8
    dragOffset = translation * resistance

    sheetViewModel.isDragging = true
    sheetViewModel.dragOffset = dragOffset

    configuration.onDragging?(translation)

    if abs(translation) > 50 && abs(dragOffset) < 1 {
      UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
  }

  private func handleDragEnd(translation: CGFloat, geometry: GeometryProxy) {
    let sortedDetents = configuration.sortedDetents

    guard let currentIndex = sortedDetents.firstIndex(of: sheetViewModel.currentDetent) else {
      return
    }

    // Dismiss if dragging down beyond threshold from the smallest detent
    if translation > configuration.dismissThreshold && sheetViewModel.isSmallest {
      withAnimation(.interactiveSpring(response: 0.4, dampingFraction: 0.8)) {
        dragOffset = 0
      }
      onRequestDismiss()
      return
    }

    let newDetent = determineNewDetent(
      translation: translation,
      currentIndex: currentIndex,
      sortedDetents: sortedDetents,
      geometry: geometry
    )

    animateToDetent(newDetent)

    if newDetent != sheetViewModel.currentDetent {
      UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
  }

  private func determineNewDetent(
    translation: CGFloat,
    currentIndex: Int,
    sortedDetents: [SheetDetent],
    geometry: GeometryProxy
  ) -> SheetDetent {
    let threshold: CGFloat = configuration.detentHopThreshold

    // Check for threshold-based navigation
    if translation > threshold && currentIndex > 0 {
      return sortedDetents[currentIndex - 1]
    }

    if translation < -threshold && currentIndex < sortedDetents.count - 1 {
      return sortedDetents[currentIndex + 1]
    }

    // Find closest detent by position
    return findClosestDetent(
      currentY: calculatedOffset(for: sheetViewModel.currentDetent, geometry: geometry)
        + dragOffset,
      sortedDetents: sortedDetents,
      geometry: geometry
    )
  }

  private func findClosestDetent(
    currentY: CGFloat,
    sortedDetents: [SheetDetent],
    geometry: GeometryProxy
  ) -> SheetDetent {
    var closestDetent = sheetViewModel.currentDetent
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
  }

  private func animateToDetent(_ detent: SheetDetent) {
    withAnimation(.interactiveSpring(response: 0.4, dampingFraction: 0.8)) {
      sheetViewModel.currentDetent = detent
      dragOffset = 0

      sheetViewModel.updateCurrentDetent(detent)
      sheetViewModel.isDragging = false
      sheetViewModel.dragOffset = 0
    }
  }

  private func calculatedOffset(for detent: SheetDetent, geometry: GeometryProxy) -> CGFloat {
    let safeAreaHeight = geometry.safeAreaInsets.bottom
    let availableHeight = geometry.size.height - safeAreaHeight
    return detent.calculateHeight(in: availableHeight)
  }
}

private struct DragHandle: View {
  var body: some View {
    Capsule()
      .fill(.quaternary.opacity(1))
      .frame(width: 36, height: 5)
      .padding(.top, 4)
      .padding(.bottom, 0)
  }
}
