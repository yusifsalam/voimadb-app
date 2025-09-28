import Fluent

struct CreateClubs: AsyncMigration {
    func prepare(on database: any Database) async throws {
        return try await database.schema("clubs")
            .field("id", .int, .identifier(auto: true))
            .field("name", .string, .required)
            .field("shortname", .string, .required)
            .field("municipality", .string)
            .field("website", .string)
            .field("active", .bool, .sql(.default(false)))
            .create()
    }
    
    func revert(on database: any Database) async throws {
        return try await database.schema("clubs").delete()
    }
}
