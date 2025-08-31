//
//  AuthService.swift
//  greenlake-companion
//
//  Created by Akmal Ariq on 29/08/25.
//

import Foundation

class AuthService {
  static let shared = AuthService()
  private let networkManager: NetworkManager

  private init() {
    self.networkManager = NetworkManager()
  }

  // MARK: - Login
  func login(email: String, password: String) async throws -> AuthData {
    let loginRequest = LoginRequest(email: email, password: password)

    do {
      let response: APIResponse<AuthData> = try await networkManager.request(
        AuthEndpoint.login,
        with: loginRequest
      )

      return response.data
    } catch let networkError as NetworkError {
      throw networkError
    } catch {
      throw NetworkError.decodingError(error)
    }
  }

  // MARK: - Refresh Token
  func refreshToken() async throws -> Tokens {
    guard let refreshToken = AuthManager.shared.refreshToken else {
      throw NetworkError.unauthorized
    }

    let refreshRequest = RefreshTokenRequest(token: refreshToken)

    do {
      let response: RefreshTokenResponse = try await networkManager.request(
        AuthEndpoint.refreshToken,
        with: refreshRequest
      )

      guard let tokens = response.data else {
        throw NetworkError.invalidResponse
      }

      return tokens
    } catch let networkError as NetworkError {
      throw networkError
    } catch {
      throw NetworkError.decodingError(error)
    }
  }

  // MARK: - Logout
  func logout() async throws {
    do {
      let _: [String: String] = try await networkManager.request(AuthEndpoint.logout)
      // Logout successful, no response data needed
    } catch let networkError as NetworkError {
      // Even if logout fails on server, we should still clear local tokens
      throw networkError
    } catch {
      throw NetworkError.decodingError(error)
    }
  }

  // MARK: - Get Current User
  func getCurrentUser() async throws -> User {
    do {
      let response: [String: User] = try await networkManager.request(AuthEndpoint.me)

      // Assuming the API returns user data in a "user" key
      guard let user = response["user"] else {
        throw NetworkError.invalidResponse
      }

      return user
    } catch let networkError as NetworkError {
      throw networkError
    } catch {
      throw NetworkError.decodingError(error)
    }
  }

  // MARK: - Generic API Request with Auth (Legacy - kept for backward compatibility)
  func authenticatedRequest<T: Decodable>(
    endpoint: String, method: String = "GET", body: Data? = nil
  ) async throws -> T {
    // This method is kept for backward compatibility but should be replaced
    // with direct NetworkManager usage in new code

    // Convert the legacy parameters to an APIEndpoint
    let legacyEndpoint = LegacyEndpoint(path: endpoint, httpMethod: method, body: body)

    do {
      if let body = body {
        // For requests with body, we need to decode the body first
        // This is a limitation of the legacy approach
        throw NetworkError.encodingError(
          NSError(
            domain: "LegacyAPI", code: -1,
            userInfo: [
              NSLocalizedDescriptionKey:
                "Legacy authenticatedRequest with body is not supported. Use NetworkManager directly."
            ]))
      } else {
        // Use the raw data request method and then decode
        let data = try await networkManager.request(legacyEndpoint)
        return try JSONDecoder().decode(T.self, from: data)
      }
    } catch let networkError as NetworkError {
      throw networkError
    } catch {
      throw NetworkError.decodingError(error)
    }
  }
}

// MARK: - Legacy Endpoint Support
private struct LegacyEndpoint: APIEndpoint {
  let path: String
  let httpMethod: String
  let body: Data?

  var method: HTTPMethod {
    switch httpMethod.uppercased() {
    case "GET": return .GET
    case "POST": return .POST
    case "PUT": return .PUT
    case "DELETE": return .DELETE
    case "PATCH": return .PATCH
    default: return .GET
    }
  }
}
