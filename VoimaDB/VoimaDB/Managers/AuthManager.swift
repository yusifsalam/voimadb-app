import Foundation
import SwiftUI

@Observable
class AuthManager {
    var currentUser: User?
    var token: String?
    var isAuthenticated: Bool {
        token != nil && currentUser != nil
    }

    private let tokenKey = "auth_token"

    init() {
        // Load saved token on init
        if let savedToken = UserDefaults.standard.string(forKey: tokenKey) {
            token = savedToken
            Task {
                await loadCurrentUser()
            }
        }
    }

    // MARK: - Login

    func login(email: String, password: String) async throws {
        let userToken = try await AuthService.shared.login(email: email, password: password)
        token = userToken.value

        // Save token to UserDefaults
        UserDefaults.standard.set(userToken.value, forKey: tokenKey)

        // Fetch current user
        await loadCurrentUser()
    }

    // MARK: - Register

    func register(name: String, email: String, password: String, confirmPassword: String) async throws {
        let user = try await AuthService.shared.register(
            name: name,
            email: email,
            password: password,
            confirmPassword: confirmPassword
        )

        // After registration, login
        try await login(email: email, password: password)
    }

    // MARK: - Logout

    func logout() {
        currentUser = nil
        token = nil
        UserDefaults.standard.removeObject(forKey: tokenKey)
    }

    // MARK: - Load Current User

    private func loadCurrentUser() async {
        guard let token = token else {
            currentUser = nil
            return
        }

        do {
            currentUser = try await AuthService.shared.getCurrentUser(token: token)
        } catch {
            // If token is invalid, clear it
            logout()
        }
    }
}
