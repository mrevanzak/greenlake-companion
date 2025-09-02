//
//  LoginView.swift
//  greenlake-companion
//
//  Created by Akmal Ariq on 29/08/25.
//

import SwiftUI
import Combine

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    @EnvironmentObject private var authManager: AuthManager
    @State private var orientation = UIDevice.current.orientation
    @FocusState private var focusedField: Field?
    @StateObject private var keyboard = KeyboardResponder()
    
    enum Field {
        case email, password
    }
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ZStack {
                    Color(.systemGroupedBackground).ignoresSafeArea()
                    
                    HStack(spacing: 0) {
                        brandingSection
                            .frame(width: geometry.size.width * 0.45)
                            .background(
                                LinearGradient(
                                    colors: [Color.green.opacity(0.05), Color.blue.opacity(0.05)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        
                        ScrollView {
                            VStack {
                                formSection
                                Spacer()
                            }
                            .padding(.bottom, min(keyboard.currentHeight,10))
                            .animation(.easeOut(duration: 0.25), value: min(keyboard.currentHeight,10))
                        }
                        .frame(width: geometry.size.width * 0.55)
                        .background(Color(.systemBackground))
                        .onTapGesture {
                            hideKeyboard()
                        }
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
            ZStack {
                Circle()
                    .fill(
                        AngularGradient(
                            colors: [
                                Color.green.opacity(0.1),
                                Color.blue.opacity(0.1),
                                Color.green.opacity(0.1),
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
            
            Text("Greenlake Companion")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.primary)
            
            Text("Your partner in site management")
                .font(.system(size: 17))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
        }
        .padding(40)
    }
    
    private var formSection: some View {
        VStack(spacing: 32) {
            VStack(spacing: 8) {
                Text("Welcome Back")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.primary)
                
                Text("Sign in to continue to your dashboard")
                    .font(.system(size: 17))
                    .foregroundColor(.secondary)
            }
            .padding(.top, 128)
            
            VStack(spacing: 20) {
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
            .padding(.top, 8)
            
            Spacer()
        }
        .padding(.vertical, 12)
    }
}

struct DeviceRotationViewModifier: ViewModifier {
  let action: (UIDeviceOrientation) -> Void

  func body(content: Content) -> some View {
    content
      .onAppear()
      .onReceive(
        NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)
      ) { _ in
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

    UIApplication.shared.sendAction(
      #selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)

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
    let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
    return emailPred.evaluate(with: email)
  }

  private func handleError(_ error: Error) {
    if let networkError = error as? NetworkError {
      switch networkError {
      case .unauthorized:
        errorMessage = "Invalid email or password. Please check your credentials."
      case .serverError:
        errorMessage = "Server error. Please try again later."
      case .invalidURL:
        errorMessage = "Network configuration error"
      case .invalidResponse:
        errorMessage = "Invalid response from server"
      case .timeout:
        errorMessage = "Request timed out. Please check your internet connection."
      case .noInternetConnection:
        errorMessage = "No internet connection. Please check your network settings."
      case .decodingError:
        errorMessage = "Failed to process server response. Please try again."
      case .encodingError:
        errorMessage = "Failed to prepare request data. Please try again."
      case .forbidden:
        errorMessage = "Access denied. Please contact support."
      case .tokenExpired:
        errorMessage = "Session expired. Please log in again."
      case .rateLimitExceeded:
        errorMessage = "Too many requests. Please wait a moment and try again."
      case .serviceUnavailable:
        errorMessage = "Service temporarily unavailable. Please try again later."
      case .certificateError:
        errorMessage = "Security certificate error. Please contact support."
      case .networkConfigurationError:
        errorMessage = "Network configuration error. Please check your settings."
      case .invalidData:
        errorMessage = "Invalid data received from server. Please try again."
      case .httpError(let statusCode):
        if (400...499).contains(statusCode) {
          errorMessage = "Client error (\(statusCode)). Please check your request and try again."
        } else if (500...599).contains(statusCode) {
          errorMessage = "Server error (\(statusCode)). Please try again later."
        } else {
          errorMessage = "HTTP error (\(statusCode)). Please try again."
        }
      }
    } else {
      errorMessage = "An unexpected error occurred. Please try again."
    }
  }
}

#Preview() {
  LoginView()
    .environmentObject(AuthManager.shared)
}

func hideKeyboard() {
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
}
