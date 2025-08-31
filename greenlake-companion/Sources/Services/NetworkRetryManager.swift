//
//  NetworkRetryManager.swift
//  greenlake-companion
//
//  Created by AI Assistant on 28/08/25.
//

import Foundation

/// Protocol defining retry behavior for network requests
protocol NetworkRetryManagerProtocol {
  /// Execute a network request with retry logic
  /// - Parameters:
  ///   - maxAttempts: Maximum number of retry attempts
  ///   - operation: The network operation to retry
  /// - Returns: The result of the network operation
  func executeWithRetry<T>(
    maxAttempts: Int,
    operation: @escaping () async throws -> T
  ) async throws -> T
}

/// Manages retry logic for network requests
class NetworkRetryManager: NetworkRetryManagerProtocol {
  // MARK: - Properties

  private let maxRetryAttempts: Int
  private let baseDelay: TimeInterval

  // MARK: - Initialization

  init(
    maxRetryAttempts: Int = NetworkConstants.defaultMaxRetryAttempts, baseDelay: TimeInterval = 1.0
  ) {
    self.maxRetryAttempts = maxRetryAttempts
    self.baseDelay = baseDelay
  }

  // MARK: - NetworkRetryManagerProtocol Implementation

  func executeWithRetry<T>(
    maxAttempts: Int,
    operation: @escaping () async throws -> T
  ) async throws -> T {
    var lastError: Error?
    let attempts = min(maxAttempts, self.maxRetryAttempts)

    for attempt in 1...attempts {
      do {
        return try await operation()
      } catch let error as NetworkError {
        lastError = error

        // Check if the error is retryable
        guard error.isRetryable else {
          throw error
        }

        // If this is the last attempt, throw the error
        guard attempt < attempts else {
          throw error
        }

        // Calculate delay with exponential backoff
        let delay = calculateDelay(for: attempt, baseDelay: baseDelay)

        // Log retry attempt
        print("Network request failed (attempt \(attempt)/\(attempts)), retrying in \(delay)s...")

        // Wait before retrying
        try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))

      } catch {
        // Non-NetworkError, don't retry
        throw error
      }
    }

    // This should never be reached, but just in case
    throw lastError ?? NetworkError.invalidResponse
  }

  // MARK: - Private Methods

  /// Calculate delay for retry attempts with exponential backoff
  /// - Parameters:
  ///   - attempt: Current attempt number (1-based)
  ///   - baseDelay: Base delay in seconds
  /// - Returns: Delay in seconds
  private func calculateDelay(for attempt: Int, baseDelay: TimeInterval) -> TimeInterval {
    let exponentialDelay = baseDelay * pow(2.0, Double(attempt - 1))
    let jitter = Double.random(in: 0...0.1) * exponentialDelay
    return min(exponentialDelay + jitter, 30.0)  // Cap at 30 seconds
  }
}

// MARK: - NetworkManager Integration

extension NetworkManager {
  /// Execute a request with retry logic
  /// - Parameters:
  ///   - endpoint: The API endpoint to request
  ///   - maxRetryAttempts: Maximum number of retry attempts
  /// - Returns: Decoded response of type T
  func requestWithRetry<T: Codable>(
    _ endpoint: APIEndpoint,
    maxRetryAttempts: Int = NetworkConstants.defaultMaxRetryAttempts
  ) async throws -> T {
    let retryManager = NetworkRetryManager(maxRetryAttempts: maxRetryAttempts)

    return try await retryManager.executeWithRetry(maxAttempts: maxRetryAttempts) {
      try await self.request(endpoint)
    }
  }

  /// Execute a request with retry logic and custom body
  /// - Parameters:
  ///   - endpoint: The API endpoint to request
  ///   - body: The request body to send
  ///   - maxRetryAttempts: Maximum number of retry attempts
  /// - Returns: Decoded response of type T
  func requestWithRetry<T: Codable>(
    _ endpoint: APIEndpoint,
    with body: Encodable,
    maxRetryAttempts: Int = NetworkConstants.defaultMaxRetryAttempts
  ) async throws -> T {
    let retryManager = NetworkRetryManager(maxRetryAttempts: maxRetryAttempts)

    return try await retryManager.executeWithRetry(maxAttempts: maxRetryAttempts) {
      try await self.request(endpoint, with: body)
    }
  }
}
