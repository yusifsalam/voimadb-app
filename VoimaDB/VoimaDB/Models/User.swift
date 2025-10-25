import Foundation

struct User: Codable, Identifiable {
    let id: UUID
    let name: String
    let email: String
    let createdAt: Date?
    let updatedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case email
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct UserToken: Codable {
    let id: UUID
    let user: UserReference
    let value: String
    let expiresAt: Date
    let isRevoked: Bool
    let createdAt: Date?

    var userId: UUID {
        user.id
    }
}

struct UserReference: Codable {
    let id: UUID
}

struct UserRegistration: Codable {
    let name: String
    let email: String
    let password: String
    let confirmPassword: String
}
