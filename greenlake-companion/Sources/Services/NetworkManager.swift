//
//  NetworkManager.swift
//  greenlake-companion
//
//  Created by AI Assistant on 28/08/25.
//

import Foundation

/// Protocol defining network management operations for dependency injection and testing
protocol NetworkManagerProtocol {
  /// Make a network request and decode the response to a specific type
  /// - Parameter endpoint: The API endpoint to request
  /// - Returns: Decoded response of type T
  func request<T: Codable>(_ endpoint: APIEndpoint) async throws -> T

  /// Make a network request and return raw data
  /// - Parameter endpoint: The API endpoint to request
  /// - Returns: Raw response data
  func request(_ endpoint: APIEndpoint) async throws -> Data

  /// Make a network request with a custom body and decode the response
  /// - Parameters:
  ///   - endpoint: The API endpoint to request
  ///   - body: The request body to send
  /// - Returns: Decoded response of type T
  func request<T: Codable>(_ endpoint: APIEndpoint, with body: Encodable) async throws -> T

  /// Make a multipart form data request with file uploads
  /// - Parameters:
  ///   - endpoint: The API endpoint to request
  ///   - request: The request body to send as form fields
  ///   - files: Array of file data to upload
  ///   - fileFieldName: The field name for file uploads (default: "files")
  /// - Returns: Decoded response of type T
  func uploadMultipart<T: Codable>(
    _ endpoint: APIEndpoint,
    with request: Encodable,
    files: [Data],
    fileFieldName: String
  ) async throws -> T
}

/// Centralized network management service for handling all API requests
class NetworkManager: NetworkManagerProtocol {
  // MARK: - Properties

  private let baseURL: String
  private let session: URLSession
  private let decoder: JSONDecoder
  private let encoder: JSONEncoder
  private let timeoutInterval: TimeInterval

  // MARK: - Initialization

  init(
    baseURL: String = NetworkConstants.defaultBaseURL,
    session: URLSession = .shared,
    decoder: JSONDecoder = JSONDecoder(),
    encoder: JSONEncoder = JSONEncoder(),
    timeoutInterval: TimeInterval = NetworkConstants.defaultTimeoutInterval
  ) {
    self.baseURL = baseURL
    self.session = session
    self.decoder = decoder
    self.encoder = encoder
    self.timeoutInterval = timeoutInterval

    // Configure decoders with app-specific settings
    // Use .useDefaultKeys since the API already uses camelCase
    self.decoder.keyDecodingStrategy = .useDefaultKeys

    // Configure date decoding to handle ISO 8601 with milliseconds and Z timezone
    self.decoder.dateDecodingStrategy = .custom { decoder in
      let container = try decoder.singleValueContainer()
      let dateString = try container.decode(String.self)

      // Try parsing with ISO8601DateFormatter first
      let isoFormatter = ISO8601DateFormatter()
      if let date = isoFormatter.date(from: dateString) {
        return date
      }

      // Try parsing with DateFormatter for more flexible ISO 8601 formats
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
      dateFormatter.timeZone = TimeZone(abbreviation: "UTC")

      if let date = dateFormatter.date(from: dateString) {
        return date
      }

      // Try without milliseconds
      dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
      if let date = dateFormatter.date(from: dateString) {
        return date
      }

      throw DecodingError.dataCorruptedError(
        in: container,
        debugDescription: "Date string does not match expected format: \(dateString)"
      )
    }

    // Configure encoders with app-specific settings
    // Use .useDefaultKeys since we want to keep camelCase
    self.encoder.keyEncodingStrategy = .useDefaultKeys

    // Configure date encoding to match the custom decoding strategy
    self.encoder.dateEncodingStrategy = .custom { date, encoder in
      var container = encoder.singleValueContainer()

      // Use DateFormatter to match the decoding format
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
      dateFormatter.timeZone = TimeZone(abbreviation: "UTC")

      let dateString = dateFormatter.string(from: date)
      try container.encode(dateString)
    }
  }

  // MARK: - NetworkManagerProtocol Implementation

  func request<T: Codable>(_ endpoint: APIEndpoint) async throws -> T {
    let data = try await request(endpoint)
    return try decoder.decode(T.self, from: data)
  }

  func request(_ endpoint: APIEndpoint) async throws -> Data {
    let request = try buildRequest(for: endpoint)
    return try await performRequest(request)
  }

  func request<T: Codable>(_ endpoint: APIEndpoint, with body: Encodable) async throws -> T {
    let request = try buildRequest(for: endpoint, with: body)
    let data = try await performRequest(request)
    return try decoder.decode(T.self, from: data)
  }

  func uploadMultipart<T: Codable>(
    _ endpoint: APIEndpoint,
    with request: Encodable,
    files: [Data],
    fileFieldName: String = "files"
  ) async throws -> T {
    let multipartRequest = try buildMultipartRequest(
      for: endpoint, with: request, files: files, fileFieldName: fileFieldName)
    let data = try await performRequest(multipartRequest)
    return try decoder.decode(T.self, from: data)
  }

  // MARK: - Private Methods

  /// Build a URLRequest for the given endpoint
  private func buildRequest(for endpoint: APIEndpoint) throws -> URLRequest {
    return try buildRequest(for: endpoint, with: endpoint.body)
  }

  /// Build a URLRequest for the given endpoint with a custom body
  private func buildRequest(for endpoint: APIEndpoint, with body: Encodable?) throws -> URLRequest {
    // Construct the full URL
    var urlComponents = URLComponents(string: baseURL + endpoint.path)

    // Add query parameters if present
    if let queryParams = endpoint.queryParameters {
      urlComponents?.queryItems = queryParams.map { key, value in
        URLQueryItem(name: key, value: value)
      }
    }

    guard let url = urlComponents?.url else {
      throw NetworkError.invalidURL
    }

    // Create the request
    var request = URLRequest(url: url)
    request.httpMethod = endpoint.method.rawValue
    request.timeoutInterval = timeoutInterval

    // Set default headers
    NetworkConstants.defaultHeaders.forEach { key, value in
      request.setValue(value, forHTTPHeaderField: key)
    }

    // Set custom headers if provided
    endpoint.headers?.forEach { key, value in
      request.setValue(value, forHTTPHeaderField: key)
    }

    // Add authentication header for protected endpoints if not already set
    if endpoint.headers?["Authorization"] == nil && requiresAuthentication(endpoint) {
      if let token = AuthManager.shared.accessToken {
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
      }
    }

    // Set request body if provided
    if let body = body {
      do {
        request.httpBody = try encoder.encode(body)
      } catch {
        throw NetworkError.encodingError(error)
      }
    }
    
    print("➡️ Network request URL: \(request.url?.absoluteString ?? "Invalid URL")")
    print("➡️ HTTP Method: \(request.httpMethod ?? "NO METHOD")")

    return request
  }

  /// Build a multipart form data URLRequest for file uploads
  private func buildMultipartRequest(
    for endpoint: APIEndpoint,
    with body: Encodable,
    files: [Data],
    fileFieldName: String
  ) throws -> URLRequest {
    // Construct the full URL
    var urlComponents = URLComponents(string: baseURL + endpoint.path)

    // Add query parameters if present
    if let queryParams = endpoint.queryParameters {
      urlComponents?.queryItems = queryParams.map { key, value in
        URLQueryItem(name: key, value: value)
      }
    }

    guard let url = urlComponents?.url else {
      throw NetworkError.invalidURL
    }

    // Create the request
    var request = URLRequest(url: url)
    request.httpMethod = endpoint.method.rawValue
    request.timeoutInterval = timeoutInterval

    // Create multipart form data
    let boundary = "Boundary-\(UUID().uuidString)"
    request.setValue(
      "multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

    // Set custom headers if provided (but don't override Content-Type)
    endpoint.headers?.forEach { key, value in
      if key.lowercased() != "content-type" {
        request.setValue(value, forHTTPHeaderField: key)
      }
    }

    // Add authentication header for protected endpoints if not already set
    if endpoint.headers?["Authorization"] == nil && requiresAuthentication(endpoint) {
      if let token = AuthManager.shared.accessToken {
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
      }
    }

    // Build multipart body
    var bodyData = Data()

    // Add form fields from the request object
    do {
      let jsonData = try encoder.encode(body)
      if let jsonObject = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any] {
        for (key, value) in jsonObject {
          let stringValue: String
          if let dateValue = value as? Date {
            // Format date as ISO string
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
            dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
            stringValue = dateFormatter.string(from: dateValue)
          } else {
            stringValue = String(describing: value)
          }

          bodyData.append("--\(boundary)\r\n".data(using: .utf8)!)
          bodyData.append(
            "Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
          bodyData.append("\(stringValue)\r\n".data(using: .utf8)!)
        }
      }
    } catch {
      throw NetworkError.encodingError(error)
    }

    // Add file uploads
    for (index, fileData) in files.enumerated() {
      bodyData.append("--\(boundary)\r\n".data(using: .utf8)!)
      bodyData.append(
        "Content-Disposition: form-data; name=\"\(fileFieldName)\"; filename=\"image_\(index).jpg\"\r\n"
          .data(using: .utf8)!)
      bodyData.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
      bodyData.append(fileData)
      bodyData.append("\r\n".data(using: .utf8)!)
    }

    // Close boundary
    bodyData.append("--\(boundary)--\r\n".data(using: .utf8)!)

    request.httpBody = bodyData

    return request
  }

  /// Determine if an endpoint requires authentication
  private func requiresAuthentication(_ endpoint: APIEndpoint) -> Bool {
    // Public endpoints that don't require authentication
    let publicEndpoints: [String] = [
      "/auth/login",
      "/auth/refresh",
    ]

    // Check if the endpoint path is in the public endpoints list
    return !publicEndpoints.contains(endpoint.path)
  }

  /// Perform the actual network request
  private func performRequest(_ request: URLRequest) async throws -> Data {
    let startTime = Date()
    var success = false
    var requestError: Error?

    // Record metrics for monitoring
    defer {
      let duration = Date().timeIntervalSince(startTime)
      let endpoint = request.url?.path ?? "unknown"

      NetworkMonitoringService.shared.recordRequest(
        endpoint: endpoint,
        duration: duration,
        success: success,
        error: requestError
      )
    }

    do {
      let (data, response) = try await session.data(for: request)

      // Validate the response
      try validateResponse(response)

      success = true
      return data
    } catch let error as NetworkError {
      requestError = error
      throw error
    } catch {
      requestError = error
      // Convert other errors to appropriate NetworkError types
      if let urlError = error as? URLError {
        throw convertURLError(urlError)
      } else {
        throw NetworkError.invalidResponse
      }
    }
  }

  /// Validate the HTTP response
  private func validateResponse(_ response: URLResponse) throws {
    guard let httpResponse = response as? HTTPURLResponse else {
      throw NetworkError.invalidResponse
    }

    // Check for successful status codes
    guard (200...299).contains(httpResponse.statusCode) else {
      // Map specific status codes to appropriate errors
      switch httpResponse.statusCode {
      case 401:
        throw NetworkError.unauthorized
      case 403:
        throw NetworkError.forbidden
      case 404:
        throw NetworkError.httpError(statusCode: httpResponse.statusCode)
      case 429:
        throw NetworkError.rateLimitExceeded
      case 500...599:
        throw NetworkError.serverError
      default:
        throw NetworkError.httpError(statusCode: httpResponse.statusCode)
      }
    }
  }

  /// Convert URLError to NetworkError
  private func convertURLError(_ urlError: URLError) -> NetworkError {
    switch urlError.code {
    case .timedOut:
      return .timeout
    case .notConnectedToInternet:
      return .noInternetConnection
    case .cannotFindHost, .cannotConnectToHost:
      return .networkConfigurationError
    case .serverCertificateUntrusted, .serverCertificateHasBadDate:
      return .certificateError
    default:
      return .networkConfigurationError
    }
  }
}

// MARK: - NetworkManager Extensions

extension NetworkManager {
  /// Create a NetworkManager configured for testing
  static func testing(
    baseURL: String = "https://test-api.greenlake.com/v1",
    session: URLSession = .shared
  ) -> NetworkManager {
    return NetworkManager(
      baseURL: baseURL,
      session: session,
      timeoutInterval: 5.0
    )
  }

  /// Create a NetworkManager configured for development
  static func development(
    baseURL: String = "https://dev-api.greenlake.com/v1",
    session: URLSession = .shared
  ) -> NetworkManager {
    return NetworkManager(
      baseURL: baseURL,
      session: session,
      timeoutInterval: 15.0
    )
  }
}
