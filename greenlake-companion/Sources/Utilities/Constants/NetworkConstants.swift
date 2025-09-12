//
//  NetworkConstants.swift
//  greenlake-companion
//
//  Created by AI Assistant on 28/08/25.
//

import Foundation

/// Centralized network configuration constants
enum NetworkConstants {
  /// Default base URL for the GreenLake API
  static let defaultBaseURL = "https://citraland.site/api"

  /// Default request timeout interval in seconds
  static let defaultTimeoutInterval: TimeInterval = 30.0

  /// Default maximum number of retry attempts for failed requests
  static let defaultMaxRetryAttempts = 3

  /// Default headers for all requests
  static let defaultHeaders: [String: String] = [
    "Content-Type": "application/json",
    "Accept": "application/json",
  ]
}

/// HTTP methods supported by the API
enum HTTPMethod: String, CaseIterable {
  case GET = "GET"
  case POST = "POST"
  case PUT = "PUT"
  case DELETE = "DELETE"
  case PATCH = "PATCH"
}

/// Protocol defining API endpoint structure
protocol APIEndpoint {
  /// The path component of the endpoint (e.g., "/plants")
  var path: String { get }

  /// The HTTP method for this endpoint
  var method: HTTPMethod { get }

  /// Optional custom headers for this specific endpoint
  var headers: [String: String]? { get }

  /// Optional request body for POST/PUT/PATCH requests
  var body: Encodable? { get }

  /// Optional query parameters for GET requests
  var queryParameters: [String: String]? { get }

  /// Whether this request should show the global loading alert (default: true)
  var showsGlobalLoading: Bool { get }
}

/// Default implementation for common endpoint properties
extension APIEndpoint {
  var headers: [String: String]? { nil }
  var body: Encodable? { nil }
  var queryParameters: [String: String]? { nil }
  var showsGlobalLoading: Bool { true }
}

/// Plant-specific API endpoints
enum PlantEndpoint: APIEndpoint {
  case fetchPlants
  case fetchPlant(id: UUID)
  case countPlants
  case createPlant
  case updatePlant(id: UUID)
  case deletePlant(id: UUID)

  var path: String {
    switch self {
    case .fetchPlants:
      return "/plants"
    case .fetchPlant(let id):
      return "/plants/\(id)"
    case .countPlants:
      return "/plants/type/count"
    case .createPlant:
      return "/plants/create"
    case .updatePlant(let id):
      return "/plants/\(id)"
    case .deletePlant(let id):
      return "/plants/\(id)"
    }
  }

  var method: HTTPMethod {
    switch self {
    case .fetchPlants, .fetchPlant, .countPlants:
      return .GET
    case .createPlant:
      return .POST
    case .updatePlant:
      return .PUT
    case .deletePlant:
      return .DELETE
    }
  }

  var body: Encodable? {
    switch self {
    case .createPlant, .updatePlant:
      // This will be set by the service when making the request
      return nil
    default:
      return nil
    }
  }
}

/// Authentication-specific API endpoints
enum AuthEndpoint: APIEndpoint {
  case login
  case logout
  case refreshToken
  case me

  var path: String {
    switch self {
    case .login:
      return "/auth/login"
    case .logout:
      return "/auth/logout"
    case .refreshToken:
      return "/auth/refresh"
    case .me:
      return "/auth/me"
    }
  }

  var method: HTTPMethod {
    switch self {
    case .login, .refreshToken:
      return .POST
    case .logout:
      return .POST
    case .me:
      return .GET
    }
  }

  var body: Encodable? {
    switch self {
    case .login, .refreshToken:
      // This will be set by the service when making the request
      return nil
    default:
      return nil
    }
  }

  var showsGlobalLoading: Bool {
    switch self {
    case .refreshToken:
      return false
    default:
      return true
    }
  }
}

/// Task-specific API endpoints
enum TaskEndpoint: APIEndpoint {
  case createTask
  case fetchTasks
  case fetchActiveTasks
  case fetchTask(id: UUID)
  case fetchTimeline(id: UUID)
  case updateTask(id: UUID)
  case updateStatus(id: UUID)
  case deleteTask(id: UUID)

  var path: String {
    switch self {
    case .createTask:
      return "/tasks/create"
    case .fetchTasks:
      return "/tasks"
    case .fetchActiveTasks:
      return "/tasks/active"
    case .fetchTask(let id):
      return "/tasks/\(id)"
    case .fetchTimeline(let id):
      return "/tasks/\(id)/timeline"
    case .updateTask(let id):
      return "/tasks/\(id)"
    case .updateStatus(let id):
      return "/tasks/\(id)/status"
    case .deleteTask(let id):
      return "/tasks/\(id)"
    }
  }

  var method: HTTPMethod {
    switch self {
    case .createTask:
      return .POST
    case .fetchTasks, .fetchActiveTasks, .fetchTask, .fetchTimeline:
      return .GET
    case .updateTask, .updateStatus:
      return .PUT
    case .deleteTask:
      return .DELETE
    }
  }

  var body: Encodable? {
    switch self {
    case .createTask, .updateTask, .updateStatus:
      // This will be set by the service when making the request
      return nil
    default:
      return nil
    }
  }

  var showsGlobalLoading: Bool {
    switch self {
    case .fetchTimeline:
      return false
    default:
      return true
    }
  }
}
