import SwiftUI

/// Environment object that provides sheet details to the content
@MainActor
class SheetViewModel: ObservableObject {
  /// The current active detent
  @Published var currentDetent: SheetDetent

  /// All available detents sorted by their order
  @Published var availableDetents: [SheetDetent]

  /// The current index of the active detent in the sorted array
  @Published var currentIndex: Int

  /// The total number of available detents
  @Published var totalDetents: Int

  /// Whether the sheet is currently being dragged
  @Published var isDragging: Bool = false

  /// The current drag offset during gesture
  @Published var dragOffset: CGFloat = 0

  init(detents: Set<SheetDetent>, initialDetent: SheetDetent) {
    let sortedDetents = Array(detents).sorted { $0.sortOrder < $1.sortOrder }
    self.availableDetents = sortedDetents
    self.currentDetent = initialDetent
    self.currentIndex = sortedDetents.firstIndex(of: initialDetent) ?? 0
    self.totalDetents = sortedDetents.count
  }

  /// Update the current detent and recalculate the index
  func updateCurrentDetent(_ detent: SheetDetent) {
    currentDetent = detent
    currentIndex = availableDetents.firstIndex(of: detent) ?? 0
  }

  /// Get the next detent if available
  var nextDetent: SheetDetent? {
    guard currentIndex < availableDetents.count - 1 else { return nil }
    return availableDetents[currentIndex + 1]
  }

  /// Get the previous detent if available
  var previousDetent: SheetDetent? {
    guard currentIndex > 0 else { return nil }
    return availableDetents[currentIndex - 1]
  }

  /// Check if the current detent is the smallest
  var isSmallest: Bool {
    currentIndex == 0
  }

  /// Check if the current detent is the largest
  var isLargest: Bool {
    currentIndex == availableDetents.count - 1
  }

  /// Get the progress from smallest to largest detent (0.0 to 1.0)
  var progress: Double {
    guard totalDetents > 1 else { return 0.0 }
    return Double(currentIndex) / Double(totalDetents - 1)
  }
}
