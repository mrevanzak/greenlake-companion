//
//  AuthService.swift
//  greenlake-companion
//
//  Created by Akmal Ariq on 29/08/25.
//


import Foundation

enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case unauthorized
    case serverError(String)
    case unknown
}

class AuthService {
    static let shared = AuthService()
    private let baseURL = "https://citraland.site/api"
    
    private init() {}
    
    // MARK: - Login
    func login(email: String, password: String) async throws -> AuthData {
        guard let url = URL(string: "\(baseURL)/auth/login") else {
            throw NetworkError.invalidURL
        }
        
        let loginRequest = LoginRequest(email: email, password: password)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONEncoder().encode(loginRequest)
        } catch {
            throw NetworkError.unknown
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        switch httpResponse.statusCode {
        case 200:
            let loginResponse = try JSONDecoder().decode(LoginResponse.self, from: data)
            guard let authData = loginResponse.data else {
                throw NetworkError.invalidResponse
            }
            return authData
        case 401:
            throw NetworkError.unauthorized
        case 400...499:
            throw NetworkError.serverError("Client error: \(httpResponse.statusCode)")
        case 500...599:
            throw NetworkError.serverError("Server error: \(httpResponse.statusCode)")
        default:
            throw NetworkError.unknown
        }
    }
    
    // MARK: - Generic API Request with Auth
    func authenticatedRequest<T: Decodable>(endpoint: String, method: String = "GET", body: Data? = nil) async throws -> T {
        guard let url = URL(string: "\(baseURL)/\(endpoint)") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add bearer token if available
        if let token = AuthManager.shared.accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        if let body = body {
            request.httpBody = body
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        switch httpResponse.statusCode {
        case 200...299:
            return try JSONDecoder().decode(T.self, from: data)
        case 401:
            throw NetworkError.unauthorized
        default:
            throw NetworkError.serverError("HTTP \(httpResponse.statusCode)")
        }
    }
}
