import Foundation

public struct UserTokenResponse: Codable, Sendable {
    public let value: String
    public let expiresAt: Date

    enum CodingKeys: String, CodingKey {
        case value
        case expiresAt = "expires_at"
    }

    public init(value: String, expiresAt: Date) {
        self.value = value
        self.expiresAt = expiresAt
    }
}
