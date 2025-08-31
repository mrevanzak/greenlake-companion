//
//  NetworkError.swift
//  greenlake-companion
//
//  Created by AI Assistant on 28/08/25.
//

import Foundation

/// Comprehensive network error types with user-friendly descriptions
enum NetworkError: LocalizedError, Identifiable, Equatable {
  // MARK: - Request Errors

  /// Invalid URL construction
  case invalidURL

  /// Invalid response format
  case invalidResponse

  /// HTTP error with specific status code
  case httpError(statusCode: Int)

  /// Request timeout
  case timeout

  /// No internet connection available
  case noInternetConnection

  // MARK: - Data Processing Errors

  /// JSON decoding failed
  case decodingError(Error)

  /// JSON encoding failed
  case encodingError(Error)

  /// Invalid data received
  case invalidData

  // MARK: - Authentication Errors

  /// Unauthorized access
  case unauthorized

  /// Forbidden access
  case forbidden

  /// Authentication token expired
  case tokenExpired

  // MARK: - Server Errors

  /// Internal server error
  case serverError

  /// Service unavailable
  case serviceUnavailable

  /// Rate limit exceeded
  case rateLimitExceeded

  // MARK: - Network Configuration Errors

  /// SSL/TLS certificate error
  case certificateError

  /// Network configuration issue
  case networkConfigurationError

  // MARK: - Identifiable

  var id: String {
    switch self {
    case .invalidURL:
      return "invalid_url"
    case .invalidResponse:
      return "invalid_response"
    case .httpError(let statusCode):
      return "http_error_\(statusCode)"
    case .timeout:
      return "timeout"
    case .noInternetConnection:
      return "no_internet"
    case .decodingError:
      return "decoding_error"
    case .encodingError:
      return "encoding_error"
    case .invalidData:
      return "invalid_data"
    case .unauthorized:
      return "unauthorized"
    case .forbidden:
      return "forbidden"
    case .tokenExpired:
      return "token_expired"
    case .serverError:
      return "server_error"
    case .serviceUnavailable:
      return "service_unavailable"
    case .rateLimitExceeded:
      return "rate_limit_exceeded"
    case .certificateError:
      return "certificate_error"
    case .networkConfigurationError:
      return "network_configuration_error"
    }
  }

  // MARK: - LocalizedError

  var errorDescription: String? {
    switch self {
    case .invalidURL:
      return "Invalid URL format"
    case .invalidResponse:
      return "Invalid response from server"
    case .httpError(let statusCode):
      return "HTTP error: \(statusCode)"
    case .timeout:
      return "Request timed out"
    case .noInternetConnection:
      return "No internet connection available"
    case .decodingError:
      return "Failed to process server response"
    case .encodingError:
      return "Failed to prepare request data"
    case .invalidData:
      return "Invalid data received from server"
    case .unauthorized:
      return "Access denied - please log in"
    case .forbidden:
      return "Access forbidden"
    case .tokenExpired:
      return "Session expired - please log in again"
    case .serverError:
      return "Server error - please try again later"
    case .serviceUnavailable:
      return "Service temporarily unavailable"
    case .rateLimitExceeded:
      return "Too many requests - please wait"
    case .certificateError:
      return "Security certificate error"
    case .networkConfigurationError:
      return "Network configuration error"
    }
  }

  var failureReason: String? {
    switch self {
    case .invalidURL:
      return "The URL could not be constructed from the provided endpoint"
    case .invalidResponse:
      return "The server response was not in the expected format"
    case .httpError(let statusCode):
      return "Server returned HTTP status code \(statusCode)"
    case .timeout:
      return "The request took longer than the allowed time limit"
    case .noInternetConnection:
      return "Device is not connected to the internet"
    case .decodingError(let error):
      return "Failed to decode response: \(error.localizedDescription)"
    case .encodingError(let error):
      return "Failed to encode request: \(error.localizedDescription)"
    case .invalidData:
      return "The server returned data that could not be processed"
    case .unauthorized:
      return "User authentication is required"
    case .forbidden:
      return "User does not have permission to access this resource"
    case .tokenExpired:
      return "Authentication token has expired and needs renewal"
    case .serverError:
      return "An internal server error occurred"
    case .serviceUnavailable:
      return "The requested service is currently unavailable"
    case .rateLimitExceeded:
      return "Too many requests were made in a short time period"
    case .certificateError:
      return "SSL/TLS certificate validation failed"
    case .networkConfigurationError:
      return "Network configuration prevents the request from completing"
    }
  }

  var recoverySuggestion: String? {
    switch self {
    case .invalidURL:
      return "Check the endpoint configuration and try again"
    case .invalidResponse:
      return "Contact support if this error persists"
    case .httpError(let statusCode):
      switch statusCode {
      case 400...499:
        return "Check your request and try again"
      case 500...599:
        return "Try again later or contact support"
      default:
        return "Try again or contact support"
      }
    case .timeout:
      return "Check your internet connection and try again"
    case .noInternetConnection:
      return "Connect to the internet and try again"
    case .decodingError:
      return "Contact support if this error persists"
    case .encodingError:
      return "Check your data format and try again"
    case .invalidData:
      return "Contact support if this error persists"
    case .unauthorized:
      return "Log in to your account and try again"
    case .forbidden:
      return "Contact support if you believe this is an error"
    case .tokenExpired:
      return "Log in again to refresh your session"
    case .serverError:
      return "Try again later or contact support"
    case .serviceUnavailable:
      return "Try again later or check service status"
    case .rateLimitExceeded:
      return "Wait a few minutes before trying again"
    case .certificateError:
      return "Contact support if this error persists"
    case .networkConfigurationError:
      return "Check your network settings or contact support"
    }
  }

  // MARK: - Equatable

  static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
    lhs.id == rhs.id
  }
}

// MARK: - NetworkError Extensions

extension NetworkError {
  /// Check if the error is retryable
  var isRetryable: Bool {
    switch self {
    case .timeout, .serverError, .serviceUnavailable, .rateLimitExceeded:
      return true
    case .httpError(let statusCode):
      // Retry on 5xx errors (server errors)
      return (500...599).contains(statusCode)
    default:
      return false
    }
  }

  /// Get the appropriate retry delay for retryable errors
  var retryDelay: TimeInterval {
    switch self {
    case .timeout:
      return 2.0
    case .rateLimitExceeded:
      return 60.0  // Wait 1 minute for rate limits
    case .serverError, .serviceUnavailable:
      return 5.0
    default:
      return 1.0
    }
  }
}
