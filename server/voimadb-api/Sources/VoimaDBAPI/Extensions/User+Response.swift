import Fluent
import VoimaDBShared

extension User {
    func toResponse() throws -> UserResponse {
        UserResponse(
            id: try self.requireID(),
            name: self.name,
            email: self.email
        )
    }
}
