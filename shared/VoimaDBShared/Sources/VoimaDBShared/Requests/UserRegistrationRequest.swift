import Foundation

public struct UserRegistrationRequest: Codable, Sendable {
    public let name: String
    public let email: String
    public let password: String
    public let confirmPassword: String

    public init(name: String, email: String, password: String, confirmPassword: String) {
        self.name = name
        self.email = email
        self.password = password
        self.confirmPassword = confirmPassword
    }
}
