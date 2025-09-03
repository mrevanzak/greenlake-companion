//
//  PlantCondition.swift
//  greenlake-companion
//
//  Created by AI Assistant on 05/01/25.
//

import Foundation
import SwiftUI

/// Plant condition tags for recording plant health status
enum PlantConditionTag: String, CaseIterable, Identifiable, Codable {
  case healthy = "Tanaman Sehat"
  case witheredLeaves = "Daun Layu"
  case brokenBranch = "Dahan Patah"
  case dead = "Tanaman Mati"

  var id: String { self.rawValue }

  /// Color associated with each condition tag
  var color: Color {
    switch self {
    case .healthy:
      return .green
    case .witheredLeaves:
      return .orange
    case .brokenBranch:
      return .red
    case .dead:
      return .gray
    }
  }

  /// SF Symbol icon for each condition tag
  var icon: String {
    switch self {
    case .healthy:
      return "leaf.fill"
    case .witheredLeaves:
      return "leaf"
    case .brokenBranch:
      return "tree"
    case .dead:
      return "xmark.circle.fill"
    }
  }
}

/// Data model representing a plant condition record
struct PlantCondition: Identifiable, Codable {
  let id: UUID
  var plantId: UUID
  var conditionTags: [PlantConditionTag]
  var description: String
  var images: [Data]
  var recordedAt: Date
  var recordedBy: String?
  var location: String?

  init(
    id: UUID = UUID(),
    plantId: UUID,
    conditionTags: [PlantConditionTag] = [],
    description: String = "",
    images: [Data] = [],
    recordedAt: Date = Date(),
    recordedBy: String? = nil,
    location: String? = nil
  ) {
    self.id = id
    self.plantId = plantId
    self.conditionTags = conditionTags
    self.description = description
    self.images = images
    self.recordedAt = recordedAt
    self.recordedBy = recordedBy
    self.location = location
  }
}

/// Plant condition recording session data
struct PlantConditionSession: Identifiable {
  let id: UUID
  var plantInstance: PlantInstance
  var selectedConditionTags: Set<PlantConditionTag>
  var description: String
  var selectedImages: [Data]
  var location: String

  init(plantInstance: PlantInstance) {
    self.id = UUID()
    self.plantInstance = plantInstance
    self.selectedConditionTags = []
    self.description = ""
    self.selectedImages = []
    self.location = "Area Taman - The GreenLake ClubHouse"
  }

  /// Convert session to PlantCondition record
  func toPlantCondition() -> PlantCondition {
    PlantCondition(
      plantId: plantInstance.id,
      conditionTags: Array(selectedConditionTags),
      description: description,
      images: selectedImages,
      recordedAt: Date(),
      location: location
    )
  }
}

// MARK: - Extensions

extension PlantCondition {
  /// Check if condition record has any images
  var hasImages: Bool {
    !images.isEmpty
  }

  /// Check if condition record has description
  var hasDescription: Bool {
    !description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
  }

  /// Get primary condition tag (first selected tag)
  var primaryCondition: PlantConditionTag? {
    conditionTags.first
  }

  /// Format recorded date for display
  var formattedDate: String {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    formatter.locale = Locale(identifier: "id_ID")
    return formatter.string(from: recordedAt)
  }
}

extension PlantConditionTag {
  /// Get all condition tags as a set for easy manipulation
  static var allTagsSet: Set<PlantConditionTag> {
    Set(allCases)
  }
}
