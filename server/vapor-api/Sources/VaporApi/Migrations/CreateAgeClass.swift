import Fluent

struct CreateAgeClass: AsyncMigration {
    func prepare(on database: any Database) async throws {
        let sex = try await database.enum("sex").read()
        return try await database.schema("age_class")
            .field("id", .int, .identifier(auto: true))
            .field("sex", sex, .required)
            .field("name", .string, .required)
            .field("lowerBound", .int16, .required)
            .field("upperBound", .int16, .required)
            .create()
    }

    func revert(on database: any Database) async throws {
        return try await database.schema("age_class").delete()
    }
}
