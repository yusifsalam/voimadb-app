import Fluent

struct CreateLifters: AsyncMigration {
    func prepare(on database: any Database) async throws {
        let sex = try await database.enum("sex")
            .case("M")
            .case("F")
            .create()
        return try await database.schema("lifters")
            .field("id", .int, .identifier(auto: true))
            .field("firstname", .string, .required)
            .field("lastname", .string, .required)
            .field("birthyear", .int, .required)
            .field("sex", sex, .required)
            .field("name", .string, .sql(.default("firstname || ' ' || lastname")))
            .field("slug", .string, .required, .sql(.default("'slug'")))
            .create()
    }

    func revert(on database: any Database) async throws {
        return try await database.schema("lifters").delete()
    }
}
