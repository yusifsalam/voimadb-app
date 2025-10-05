import Fluent
import FluentSQL

struct CreateUserTokens: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("user_tokens")
            .field("id", .uuid, .identifier(auto: false), .sql(.default(SQLFunction("uuidv7"))))
            .field("user_id", .uuid, .required, .references("users", "id", onDelete: .cascade))
            .field("value", .string, .required)
            .field("is_revoked", .bool, .required)
            .field("expires_at", .datetime, .required)
            .field("created_at", .datetime)
            .unique(on: "value")
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema("user_tokens").delete()
    }
}
