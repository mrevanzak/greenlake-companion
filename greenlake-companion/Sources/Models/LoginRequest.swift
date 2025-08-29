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

// MARK: - Login Response
struct LoginResponse: Codable {
    let success: Bool
    let message: String
    let data: AuthData?
}

struct AuthData: Codable {
    let user: User
    let tokens: Tokens
}

struct User: Codable, Identifiable {
    let id: Int
    let email: String
    let name: String
    let site: String
    let role: String
}

struct Tokens: Codable {
    let accessToken: String
    let refreshToken: String
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "accessToken"
        case refreshToken = "refreshToken"
    }
}
