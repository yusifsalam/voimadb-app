import Fluent
import FluentPostgresDriver
import JWT
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

    // JWT Configuration
    if let jwtSecret = Environment.get("JWT_SECRET") {
        await app.jwt.keys.add(hmac: HMACKey(from: jwtSecret), digestAlgorithm: .sha256)
    } else {
        app.logger.warning("JWT_SECRET not set, using default (INSECURE)")
        await app.jwt.keys.add(hmac: HMACKey(from: "secret"), digestAlgorithm: .sha256)
    }

    // Apple Sign In Configuration
    if let appleAppId = Environment.get("APPLE_APP_ID") {
        app.jwt.apple.applicationIdentifier = appleAppId
    }

    // Existing migrations
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
