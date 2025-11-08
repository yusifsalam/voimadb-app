import Foundation

public struct ErrorResponse: Codable, Sendable {
    public let error: Bool
    public let reason: String

    public init(error: Bool = true, reason: String) {
        self.error = error
        self.reason = reason
    }
}
