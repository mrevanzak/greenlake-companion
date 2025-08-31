//
//  AuthManager.swift
//  greenlake-companion
//
//  Created by Akmal Ariq on 29/08/25.
//

import Foundation
import SwiftUI

class AuthManager: ObservableObject {
  static let shared = AuthManager()

  @Published var isAuthenticated: Bool = false
  @Published var currentUser: User?

  var accessToken: String? {
    get { UserDefaults.standard.string(forKey: "accessToken") }
    set { UserDefaults.standard.set(newValue, forKey: "accessToken") }
  }

  var refreshToken: String? {
    get { UserDefaults.standard.string(forKey: "refreshToken") }
    set { UserDefaults.standard.set(newValue, forKey: "refreshToken") }
  }

  private init() {
    // Check if we have a token on app start
    if accessToken != nil {
      isAuthenticated = true
      // You might want to load user data from UserDefaults as well
    }
  }

  func login(user: User, tokens: Tokens) {
    self.currentUser = user
    self.accessToken = tokens.accessToken
    self.refreshToken = tokens.refreshToken
    self.isAuthenticated = true

    // Save user data to UserDefaults
    if let userData = try? JSONEncoder().encode(user) {
      UserDefaults.standard.set(userData, forKey: "currentUser")
    }
  }

  func logout() {
    currentUser = nil
    accessToken = nil
    refreshToken = nil
    isAuthenticated = false

    UserDefaults.standard.removeObject(forKey: "currentUser")
    UserDefaults.standard.removeObject(forKey: "accessToken")
    UserDefaults.standard.removeObject(forKey: "refreshToken")
  }

  func loadUserFromStorage() {
    if let userData = UserDefaults.standard.data(forKey: "currentUser"),
      let user = try? JSONDecoder().decode(User.self, from: userData)
    {
      self.currentUser = user
    }
  }

  // MARK: - Token Management

  /// Refresh the access token using the refresh token
  func refreshAccessToken() async throws {
    do {
      let tokens = try await AuthService.shared.refreshToken()
      self.accessToken = tokens.accessToken
      self.refreshToken = tokens.refreshToken

      // Save to UserDefaults
      UserDefaults.standard.set(tokens.accessToken, forKey: "accessToken")
      UserDefaults.standard.set(tokens.refreshToken, forKey: "refreshToken")
    } catch {
      // If refresh fails, logout the user
      logout()
      throw error
    }
  }

  /// Check if the current access token is valid
  func isTokenValid() -> Bool {
    guard let token = accessToken else { return false }

    // Basic validation - check if token exists and is not empty
    return !token.isEmpty
  }

  /// Check if the current access token needs refresh
  func needsTokenRefresh() -> Bool {
    // For now, we'll use a simple approach
    // In a production app, you might want to decode the JWT and check expiration
    return !isTokenValid()
  }

  /// Validate and refresh token if needed
  func validateAndRefreshTokenIfNeeded() async throws {
    if needsTokenRefresh() {
      try await refreshAccessToken()
    }
  }

  /// Get a valid access token, refreshing if necessary
  func getValidAccessToken() async throws -> String {
    try await validateAndRefreshTokenIfNeeded()

    guard let token = accessToken else {
      throw NetworkError.unauthorized
    }

    return token
  }
}
