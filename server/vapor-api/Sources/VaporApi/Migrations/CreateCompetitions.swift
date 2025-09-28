import Fluent

struct CreateCompetitions: AsyncMigration {
    func prepare(on database: any Database) async throws {
        let eventType = try await database.enum("event_type")
            .case("SBD")
            .case("B")
            .create()
        let equipment = try await database.enum("equipment")
            .case("Raw")
            .case("SinglePly")
            .create()
        
        return try await database.schema("competitions")
            .field("id", .int, .identifier(auto: true))
            .field("name", .string, .required)
            .field("date", .date, .required)
            .field("description", .string)
            .field("event_type", eventType, .required)
            .field("equipment", equipment, .required)
            .field("city", .string, .required)
            .field("country", .string, .required)
            .create()
    }

    func revert(on database: any Database) async throws {
        return try await database.schema("competitions").delete()
    }
}
