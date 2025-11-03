import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get { _ async in
        "VoimaDB API is running! Current time is \(Date())"
    }

    // Register controllers
    try app.register(collection: LifterController())
    try app.register(collection: CompetitionController())
    try app.register(collection: ClubController())
    try app.register(collection: ResultController())
    try app.register(collection: WeightClassController())
    try app.register(collection: AgeClassController())
    try app.register(collection: AuthController())
}
