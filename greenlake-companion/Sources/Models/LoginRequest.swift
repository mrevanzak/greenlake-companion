//
//  LoginRequest.swift
//  greenlake-companion
//
//  Created by Akmal Ariq on 29/08/25.
//

import Foundation

// MARK: - Login Request
struct LoginRequest: Codable {
  let email: String
  let password: String
}

struct AuthData: Codable {
  let user: User
  let tokens: Tokens
}

// MARK: - Refresh Token Request
struct RefreshTokenRequest: Codable {
  let token: String
}

// MARK: - Refresh Token Response
struct RefreshTokenResponse: Codable {
  let success: Bool
  let message: String
  let data: Tokens?
}
