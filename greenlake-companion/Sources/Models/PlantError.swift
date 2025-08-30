//
//  PlantError.swift
//  greenlake-companion
//
//  Created by AI Assistant on 28/08/25.
//

import Foundation

/// Comprehensive error types for plant operations
enum PlantError: LocalizedError, Identifiable {
  case loadFailed(Error)
  case createFailed(Error)
  case updateFailed(Error)
  case deleteFailed(Error)
  case networkError
  case invalidData
  case plantNotFound
  case invalidCoordinate

  var id: String {
    switch self {
    case .loadFailed: return "load_failed"
    case .createFailed: return "create_failed"
    case .updateFailed: return "update_failed"
    case .deleteFailed: return "delete_failed"
    case .networkError: return "network_error"
    case .invalidData: return "invalid_data"
    case .plantNotFound: return "plant_not_found"
    case .invalidCoordinate: return "invalid_coordinate"
    }
  }

  var errorDescription: String? {
    switch self {
    case .loadFailed(let error):
      return "Failed to load plants: \(error.localizedDescription)"
    case .createFailed(let error):
      return "Failed to create plant: \(error.localizedDescription)"
    case .updateFailed(let error):
      return "Failed to update plant: \(error.localizedDescription)"
    case .deleteFailed(let error):
      return "Failed to delete plant: \(error.localizedDescription)"
    case .networkError:
      return "Network connection error. Please check your internet connection."
    case .invalidData:
      return "Invalid plant data received from server."
    case .plantNotFound:
      return "Plant not found. It may have been deleted."
    case .invalidCoordinate:
      return "Invalid location coordinates for plant."
    }
  }

  var recoverySuggestion: String? {
    switch self {
    case .loadFailed, .createFailed, .updateFailed, .deleteFailed:
      return "Please try again. If the problem persists, contact support."
    case .networkError:
      return "Check your internet connection and try again."
    case .invalidData, .plantNotFound, .invalidCoordinate:
      return "The data may be corrupted. Please refresh the app."
    }
  }
}
