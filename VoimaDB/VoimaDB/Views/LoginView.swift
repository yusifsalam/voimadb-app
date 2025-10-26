import AuthenticationServices
import SwiftUI

struct LoginView: View {
    @Environment(AuthManager.self) private var authManager

    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showingRegister = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                VStack(spacing: 8) {
                    Image(systemName: "figure.strengthtraining.traditional")
                        .font(.system(size: 60))
                        .foregroundStyle(.blue)

                    Text("VoimaDB")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                }
                .padding(.bottom, 40)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Email")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    TextField("email@example.com", text: $email)
                        .textContentType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Password")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    SecureField("••••••••", text: $password)
                        .textContentType(.password)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                }

                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                }

                Button {
                    Task {
                        await handleLogin()
                    }
                } label: {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .tint(.white)
                            .frame(maxWidth: .infinity)
                    } else {
                        Text("Sign In")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                    }
                }
                .frame(height: 50)
                .background(email.isEmpty || password.isEmpty ? Color.gray : Color.blue)
                .foregroundStyle(.white)
                .cornerRadius(10)
                .disabled(email.isEmpty || password.isEmpty || isLoading)
                .padding(.top, 10)

                // Divider
                HStack {
                    VStack { Divider() }
                    Text("or")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    VStack { Divider() }
                }
                .padding(.vertical, 10)

                // Sign in with Apple button
                SignInWithAppleButton(
                    .signIn,
                    onRequest: { request in
                        request.requestedScopes = [.fullName, .email]
                    },
                    onCompletion: { result in
                        Task {
                            await handleAppleSignIn(result)
                        }
                    }
                )
                .frame(height: 50)
                .cornerRadius(10)
                .disabled(isLoading)

                Button {
                    showingRegister = true
                } label: {
                    Text("Don't have an account? **Sign Up**")
                        .font(.subheadline)
                }
                .padding(.top, 10)

                Spacer()
            }
            .padding(30)
            .navigationTitle("Sign In")
            .sheet(isPresented: $showingRegister) {
                RegisterView()
            }
        }
    }

    private func handleLogin() async {
        isLoading = true
        errorMessage = nil

        do {
            try await authManager.login(email: email, password: password)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    private func handleAppleSignIn(_ result: Result<ASAuthorization, Error>) async {
        isLoading = true
        errorMessage = nil

        do {
            // Extract credential from the authorization result
            let authorization = try result.get()

            guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
                  let identityTokenData = appleIDCredential.identityToken,
                  let identityToken = String(data: identityTokenData, encoding: .utf8) else {
                throw AppleSignInError.missingCredentials
            }

            // Get full name if available (only provided on first sign in)
            let fullName: String? = {
                guard let nameComponents = appleIDCredential.fullName else { return nil }
                let formatter = PersonNameComponentsFormatter()
                return formatter.string(from: nameComponents)
            }()

            // Sign in with Apple via backend
            try await authManager.signInWithApple(
                identityToken: identityToken,
                name: fullName
            )
        } catch let error as ASAuthorizationError where error.code == .canceled {
            // User cancelled, don't show error
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}

// MARK: - Apple Sign In Error

enum AppleSignInError: LocalizedError {
    case missingCredentials

    var errorDescription: String? {
        switch self {
        case .missingCredentials:
            return "Failed to get credentials from Apple"
        }
    }
}

#Preview {
    LoginView()
        .environment(AuthManager())
}
