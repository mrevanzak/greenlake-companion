//
//  LoginView.swift
//  greenlake-companion
//
//  Created by Akmal Ariq on 29/08/25.
//

import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    @EnvironmentObject private var authManager: AuthManager
    @State private var orientation = UIDevice.current.orientation
    @FocusState private var focusedField: Field?
    
    enum Field {
        case email, password
    }
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ZStack {
                    // Subtle background
                    Color(.systemGroupedBackground)
                        .ignoresSafeArea()
                    
                    if geometry.size.width > 800 {
                        // iPad layout - split view
                        HStack(spacing: 0) {
                            // Left side - Branding
                            brandingSection
                                .frame(width: geometry.size.width * 0.45)
                                .background(
                                    LinearGradient(
                                        colors: [Color.green.opacity(0.05), Color.blue.opacity(0.05)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                            
                            // Right side - Login Form
                            formSection
                                .frame(width: geometry.size.width * 0.55)
                                .background(Color(.systemBackground))
                        }
                    } else {
                        // Compact layout
                        ScrollView {
                            VStack(spacing: 0) {
                                brandingSection
                                    .padding(.top, 40)
                                
                                formSection
                                    .padding(.top, 32)
                            }
                            .padding(.horizontal, 20)
                        }
                        .background(Color(.systemBackground))
                    }
                }
            }
            .navigationBarHidden(true)
            .onRotate { newOrientation in
                orientation = newOrientation
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private var brandingSection: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Logo
            ZStack {
                Circle()
                    .fill(
                        AngularGradient(
                            colors: [
                                Color.green.opacity(0.1),
                                Color.blue.opacity(0.1),
                                Color.green.opacity(0.1)
                            ],
                            center: .center,
                            angle: .degrees(45)
                        )
                    )
                    .frame(width: 120, height: 120)
                
                Image(systemName: "leaf.fill")
                    .font(.system(size: 50, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.green, .mint],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .padding(.bottom, 8)
            
            // App name
            Text("Greenlake Companion")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.primary)
            
            // Tagline
            Text("Your partner in site management")
                .font(.system(size: 17))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
            
            // Footer
            VStack(spacing: 12) {
                Divider()
                    .padding(.horizontal, 40)
                
                Text("Version 1.0 • Built with SwiftUI")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.bottom, 20)
        }
        .padding(40)
    }
    
    private var formSection: some View {
        VStack(spacing: 32) {
            // Header
            VStack(spacing: 8) {
                Text("Welcome Back")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.primary)
                
                Text("Sign in to continue to your dashboard")
                    .font(.system(size: 17))
                    .foregroundColor(.secondary)
            }
            .padding(.top, 128)
            
            // Form fields
            VStack(spacing: 20) {
                // Email field
                VStack(alignment: .leading, spacing: 6) {
                    Text("Email Address")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    TextField("", text: $viewModel.email)
                        .focused($focusedField, equals: .email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemGray6))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(focusedField == .email ? Color.blue : Color.clear, lineWidth: 1)
                                )
                        )
                        .submitLabel(.next)
                        .onSubmit {
                            focusedField = .password
                        }
                }
                
                // Password field
                VStack(alignment: .leading, spacing: 6) {
                    Text("Password")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    SecureField("", text: $viewModel.password)
                        .focused($focusedField, equals: .password)
                        .textContentType(.password)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemGray6))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(focusedField == .password ? Color.blue : Color.clear, lineWidth: 1)
                                )
                        )
                        .submitLabel(.go)
                        .onSubmit {
                            if !viewModel.isLoading {
                                viewModel.login()
                            }
                        }
                }
            }
            .padding(.horizontal, 32)
            
            // Error message
            if let error = viewModel.errorMessage {
                HStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                        .font(.system(size: 16))
                    
                    Text(error)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Spacer()
                }
                .padding(16)
                .background(Color.orange.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal, 32)
            }
            
            // Login button
            Button(action: viewModel.login) {
                HStack {
                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Image(systemName: "arrow.right")
                            .font(.system(size: 17, weight: .semibold))
                        Text("Sign In")
                            .font(.system(size: 17, weight: .semibold))
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        colors: viewModel.isLoading ? [Color.green.opacity(0.7)] : [Color.green, Color.mint],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .foregroundColor(.white)
                .cornerRadius(14)
                .contentShape(Rectangle())
            }
            .disabled(viewModel.isLoading || viewModel.email.isEmpty || viewModel.password.isEmpty)
            .padding(.horizontal, 32)
            
            // Support link
//            Button(action: {
//                // Handle support action
//                if let url = URL(string: "mailto:support@greenlake.com") {
//                    UIApplication.shared.open(url)
//                }
//            }) {
//                Text("Need help? Contact support")
//                    .font(.subheadline)
//                    .foregroundColor(.blue)
//            }
            .padding(.top, 8)
            
            Spacer()
        }
        .padding(.vertical, 40)
    }
}

struct DeviceRotationViewModifier: ViewModifier {
    let action: (UIDeviceOrientation) -> Void
    
    func body(content: Content) -> some View {
        content
            .onAppear()
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                action(UIDevice.current.orientation)
            }
    }
}

extension View {
    func onRotate(perform action: @escaping (UIDeviceOrientation) -> Void) -> some View {
        self.modifier(DeviceRotationViewModifier(action: action))
    }
}

class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let authService = AuthService.shared
    
    func login() {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please fill in all fields"
            return
        }
        
        guard isValidEmail(email) else {
            errorMessage = "Please enter a valid email address"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        
        Task {
            do {
                let authData = try await authService.login(email: email, password: password)
                
                await MainActor.run {
                    AuthManager.shared.login(user: authData.user, tokens: authData.tokens)
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    handleError(error)
                }
            }
        }
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    private func handleError(_ error: Error) {
        if let networkError = error as? NetworkError {
            switch networkError {
            case .unauthorized:
                errorMessage = "Invalid email or password. Please check your credentials."
            case .serverError(let message):
                errorMessage = "Server error: \(message)"
            case .invalidURL:
                errorMessage = "Network configuration error"
            case .invalidResponse:
                errorMessage = "Invalid response from server"
            default:
                errorMessage = "Network connection error. Please check your internet connection."
            }
        } else {
            errorMessage = "An unexpected error occurred. Please try again."
        }
    }
}

#Preview() {
    LoginView()
}
