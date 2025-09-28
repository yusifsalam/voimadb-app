import Fluent

struct CreateResults: AsyncMigration {
    func prepare(on database: any Database) async throws {
        
        return try await database.schema("results")
            .field("id", .int, .identifier(auto: true))
            .field("competition_id", .int, .required, .references("competitions", "id"))
            .field("lifter_id", .int, .required, .references("lifters", "id"))
            .field("bodyweight", .double, .required)
            .field("club_id", .int, .references("clubs", "id"))
            .field("squat1", .double, .required)
            .field("squat1success", .bool, .required)
            .field("squat2", .double, .required)
            .field("squat2success", .bool, .required)
            .field("squat3", .double, .required)
            .field("squat3success", .bool, .required)
            .field("bestsquat", .double, .required)
            .field("bench1", .double, .required)
            .field("bench1success", .bool, .required)
            .field("bench2", .double, .required)
            .field("bench2success", .bool, .required)
            .field("bench3", .double, .required)
            .field("bench3success", .bool, .required)
            .field("bestbench", .double, .required)
            .field("deadlift1", .double, .required)
            .field("deadlift1success", .bool, .required)
            .field("deadlift2", .double, .required)
            .field("deadlift2success", .bool, .required)
            .field("deadlift3", .double, .required)
            .field("deadlift3success", .bool, .required)
            .field("bestdeadlift", .double, .required)
            .field("total", .double, .required)
            .field("points", .double, .required)
            .field("position", .int)
            .create()
    }

    func revert(on database: any Database) async throws {
        return try await database.schema("results").delete()
    }
}
