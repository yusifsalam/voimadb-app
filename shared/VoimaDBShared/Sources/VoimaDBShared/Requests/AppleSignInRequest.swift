import Foundation

public struct AppleSignInRequest: Codable, Sendable {
    public let identityToken: String
    public let name: String?

    public init(identityToken: String, name: String? = nil) {
        self.identityToken = identityToken
        self.name = name
    }
}
