import Foundation

enum AuthError: LocalizedError {
    case invalidURL
    case invalidResponse
    case unauthorized
    case serverError(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .unauthorized:
            return "Invalid email or password"
        case .serverError(let message):
            return message
        }
    }
}

class AuthService {
    static let shared = AuthService()

    private let baseURL = "http://localhost:8080"
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()

    private init() {}

    // MARK: - Register

    func register(name: String, email: String, password: String, confirmPassword: String) async throws -> User {
        guard let url = URL(string: "\(baseURL)/users") else {
            throw AuthError.invalidURL
        }

        let registration = UserRegistration(
            name: name,
            email: email,
            password: password,
            confirmPassword: confirmPassword
        )

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(registration)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw AuthError.invalidResponse
        }

        switch httpResponse.statusCode {
        case 200:
            return try decoder.decode(User.self, from: data)
        case 400:
            if let errorResponse = try? JSONDecoder().decode([String: String].self, from: data),
               let reason = errorResponse["reason"] {
                throw AuthError.serverError(reason)
            }
            throw AuthError.serverError("Registration failed")
        default:
            throw AuthError.serverError("Server error: \(httpResponse.statusCode)")
        }
    }

    // MARK: - Login

    func login(email: String, password: String) async throws -> UserToken {
        guard let url = URL(string: "\(baseURL)/login") else {
            throw AuthError.invalidURL
        }

        let credentials = "\(email):\(password)".data(using: .utf8)?.base64EncodedString() ?? ""

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Basic \(credentials)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)

        // Debug: Print raw JSON response
        if let jsonString = String(data: data, encoding: .utf8) {
            print("Login response JSON: \(jsonString)")
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw AuthError.invalidResponse
        }

        switch httpResponse.statusCode {
        case 200:
            do {
                return try decoder.decode(UserToken.self, from: data)
            } catch {
                print("Decoding error: \(error)")
                throw AuthError.serverError("Failed to decode response: \(error.localizedDescription)")
            }
        case 401:
            throw AuthError.unauthorized
        default:
            throw AuthError.serverError("Server error: \(httpResponse.statusCode)")
        }
    }

    // MARK: - Sign in with Apple

    func signInWithApple(identityToken: String, name: String?) async throws -> UserToken {
        guard let url = URL(string: "\(baseURL)/auth/apple") else {
            throw AuthError.invalidURL
        }

        let appleSignInRequest = AppleSignInRequest(
            identityToken: identityToken,
            name: name
        )

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(appleSignInRequest)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw AuthError.invalidResponse
        }

        switch httpResponse.statusCode {
        case 200:
            return try decoder.decode(UserToken.self, from: data)
        case 400, 401:
            if let errorResponse = try? JSONDecoder().decode([String: String].self, from: data),
               let reason = errorResponse["reason"] {
                throw AuthError.serverError(reason)
            }
            throw AuthError.serverError("Apple Sign In failed")
        default:
            throw AuthError.serverError("Server error: \(httpResponse.statusCode)")
        }
    }

    // MARK: - Get Current User

    func getCurrentUser(token: String) async throws -> User {
        guard let url = URL(string: "\(baseURL)/me") else {
            throw AuthError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw AuthError.invalidResponse
        }

        switch httpResponse.statusCode {
        case 200:
            return try decoder.decode(User.self, from: data)
        case 401:
            throw AuthError.unauthorized
        default:
            throw AuthError.serverError("Server error: \(httpResponse.statusCode)")
        }
    }
}

// MARK: - Apple Sign In Request

struct AppleSignInRequest: Codable {
    let identityToken: String
    let name: String?
}
