import Fluent

struct CreateTempResults: AsyncMigration {
    func prepare(on database: any Database) async throws {
        return try await database.schema("temp_results")
            .field("id", .int, .identifier(auto: true))
            .field("temp_id", .int)
            .field("competitionid", .int)
            .field("competitionname", .string)
            .field("competitiondate", .string)
            .field("competitionlocation", .string)
            .field("name", .string)
            .field("birthyear", .int)
            .field("gender", .string)
            .field("weightclass", .int)
            .field("bodyweight", .double)
            .field("club", .string)
            .field("squat1", .double)
            .field("squat1success", .string)
            .field("squat2", .double)
            .field("squat2success", .string)
            .field("squat3", .double)
            .field("squat3success", .string)
            .field("bestsquat", .double)
            .field("bench1", .double)
            .field("bench1success", .string)
            .field("bench2", .double)
            .field("bench2success", .string)
            .field("bench3", .double)
            .field("bench3success", .string)
            .field("bestbench", .double)
            .field("deadlift1", .double)
            .field("deadlift1success", .string)
            .field("deadlift2", .double)
            .field("deadlift2success", .string)
            .field("deadlift3", .double)
            .field("deadlift3success", .string)
            .field("bestdeadlift", .double)
            .field("total", .double)
            .field("points", .double)
            .field("position", .int)
            .create()
    }

    func revert(on database: any Database) async throws {
        return try await database.schema("temp_results").delete()
    }
}
