import Fluent
import VoimaDBShared

extension UserToken {
    func toResponse() -> UserTokenResponse {
        UserTokenResponse(
            value: self.value,
            expiresAt: self.expiresAt
        )
    }
}
