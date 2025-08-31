//
//  NetworkConfigurationManager.swift
//  greenlake-companion
//
//  Created by AI Assistant on 28/08/25.
//

import Foundation

/// Environment types for the application
enum Environment: String, CaseIterable {
  case development = "development"
  case staging = "staging"
  case production = "production"
  case testing = "testing"

  var displayName: String {
    switch self {
    case .development:
      return "Development"
    case .staging:
      return "Staging"
    case .production:
      return "Production"
    case .testing:
      return "Testing"
    }
  }
}

/// Centralized network configuration management
class NetworkConfigurationManager: ObservableObject {
  // MARK: - Published Properties

  @Published var currentEnvironment: Environment = .development

  // MARK: - Singleton

  static let shared = NetworkConfigurationManager()

  // MARK: - Private Properties

  private let userDefaults = UserDefaults.standard
  private let environmentKey = "NetworkEnvironment"

  // MARK: - Initialization

  private init() {
    loadEnvironment()
  }

  // MARK: - Public Methods

  /// Get the base URL for the current environment
  var baseURL: String {
    switch currentEnvironment {
    case .development:
      return "https://dev-api.greenlake.com/v1"
    case .staging:
      return "https://staging-api.greenlake.com/v1"
    case .production:
      return "https://api.greenlake.com/v1"
    case .testing:
      return "https://test-api.greenlake.com/v1"
    }
  }

  /// Get the timeout interval for the current environment
  var timeoutInterval: TimeInterval {
    switch currentEnvironment {
    case .development, .staging:
      return 15.0
    case .production:
      return 30.0
    case .testing:
      return 5.0
    }
  }

  /// Get the maximum retry attempts for the current environment
  var maxRetryAttempts: Int {
    switch currentEnvironment {
    case .development, .staging, .testing:
      return 1
    case .production:
      return 3
    }
  }

  /// Get additional headers for the current environment
  var additionalHeaders: [String: String] {
    var headers: [String: String] = [:]

    switch currentEnvironment {
    case .development:
      headers["X-Environment"] = "development"
      headers["X-Debug"] = "true"
    case .staging:
      headers["X-Environment"] = "staging"
    case .production:
      // No additional headers for production
      break
    case .testing:
      headers["X-Environment"] = "testing"
      headers["X-Test-Mode"] = "true"
    }

    return headers
  }

  /// Switch to a different environment
  /// - Parameter environment: The new environment to switch to
  func switchEnvironment(to environment: Environment) {
    currentEnvironment = environment
    saveEnvironment()

    // Post notification for environment change
    NotificationCenter.default.post(
      name: .networkEnvironmentChanged,
      object: environment
    )
  }

  /// Create a NetworkManager configured for the current environment
  func createNetworkManager() -> NetworkManager {
    return NetworkManager(
      baseURL: baseURL,
      timeoutInterval: timeoutInterval
    )
  }

  // MARK: - Private Methods

  private func loadEnvironment() {
    if let environmentString = userDefaults.string(forKey: environmentKey),
      let environment = Environment(rawValue: environmentString)
    {
      currentEnvironment = environment
    }
  }

  private func saveEnvironment() {
    userDefaults.set(currentEnvironment.rawValue, forKey: environmentKey)
  }
}

// MARK: - Notification Names

extension Notification.Name {
  static let networkEnvironmentChanged = Notification.Name("NetworkEnvironmentChanged")
}

// MARK: - Environment Switching Convenience

extension NetworkConfigurationManager {
  /// Switch to development environment
  func switchToDevelopment() {
    switchEnvironment(to: .development)
  }

  /// Switch to staging environment
  func switchToStaging() {
    switchEnvironment(to: .staging)
  }

  /// Switch to production environment
  func switchToProduction() {
    switchEnvironment(to: .production)
  }

  /// Switch to testing environment
  func switchToTesting() {
    switchEnvironment(to: .testing)
  }
}
