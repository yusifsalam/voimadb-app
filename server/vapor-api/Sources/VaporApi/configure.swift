import Fluent
import FluentPostgresDriver
import Vapor

public func configure(_ app: Application) async throws {
    try app.databases.use(.postgres(configuration: .init(
        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
        port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? 5432,
        username: Environment.get("DATABASE_USERNAME") ?? "voima",
        password: Environment.get("DATABASE_PASSWORD") ?? "voimadb",
        database: Environment.get("DATABASE_NAME") ?? "voimadb",
        tls: .prefer(.init(configuration: .clientDefault))
    )
    ), as: .psql)

    app.migrations.add(CreateLifters())
    app.migrations.add(CreateAgeClass())
    app.migrations.add(CreateClubs())
    app.migrations.add(CreateCompetitions())
    app.migrations.add(CreateWeightClass())
    app.migrations.add(CreateResults())
    app.migrations.add(CreateTempResults())
    app.migrations.add(CreateUsers())
    app.migrations.add(CreateUserTokens())

    try await app.autoMigrate()

    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    try routes(app)
}
