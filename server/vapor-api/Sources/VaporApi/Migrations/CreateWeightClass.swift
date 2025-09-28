import Fluent

struct CreateWeightClass: AsyncMigration {
    func prepare(on database: any Database) async throws {
        let sex = try await database.enum("sex").read()
        return try await database.schema("weight_class")
            .field("id", .int, .identifier(auto: true))
            .field("name", .string, .required)
            .field("sex", sex, .required)
            .field("lowerBound", .double, .required)
            .field("upperBound", .double, .required)
            .field("validFrom", .datetime, .required)
            .field("validUntil", .datetime)
            .create()
    }

    func revert(on database: any Database) async throws {
        return try await database.schema("weight_class").delete()
    }
}
