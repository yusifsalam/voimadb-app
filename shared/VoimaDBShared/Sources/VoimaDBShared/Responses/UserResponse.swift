import Foundation

public struct UserResponse: Codable, Identifiable, Sendable {
    public let id: UUID
    public let name: String
    public let email: String

    public init(id: UUID, name: String, email: String) {
        self.id = id
        self.name = name
        self.email = email
    }
}
