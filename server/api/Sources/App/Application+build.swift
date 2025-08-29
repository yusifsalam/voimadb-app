import Hummingbird
import Foundation
import HummingbirdAuth
import HummingbirdPostgres
import PostgresMigrations
import PostgresNIO
import Logging

/// Application arguments protocol. We use a protocol so we can call
/// `buildApplication` inside Tests as well as in the App executable.
/// Any variables added here also have to be added to `App` in App.swift and
/// `TestArguments` in AppTest.swift
public protocol AppArguments {
    var hostname: String { get }
    var port: Int { get }
    var logLevel: Logger.Level? { get }
    var inMemoryTesting: Bool { get }
}

// Request context used by application
typealias AppRequestContext = BasicSessionRequestContext<UUID, User>

///  Build application
/// - Parameter arguments: application arguments
public func buildApplication(_ arguments: some AppArguments) async throws -> some ApplicationProtocol {
    let env = try await Environment.dotEnv()
    let logger = {
        var logger = Logger(label: "voimadb-api")
        logger.logLevel =
        arguments.logLevel ??
        env.get("LOG_LEVEL").flatMap { Logger.Level(rawValue: $0) } ??
            .info
        return logger
    }()
    
    
    let pgClient = PostgresClient(
        configuration: .init(
            host: env.get("POSTGRES_HOST") ?? "localhost",
            port: env.get("POSTGRES_PORT").flatMap(Int.init) ?? 5432,
            username: env.get("POSTGRES_USERNAME") ?? "postgres",
            password: env.get("POSTGRES_PASSWORD") ?? "postgres",
            database: env.get("POSTGRES_DATABASE") ?? "postgres",
            tls: .disable
        ),
        backgroundLogger: logger
    )
    let compRepo = CompetitionPostgresRepository(client: pgClient, logger: logger)
    let userRepo = UserPostgresRepository(client: pgClient, logger: logger)
    
    let migrations = DatabaseMigrations()
    await migrations.add(CreateUsersTableMigration())
    await migrations.add(CreateCompetitionsTableMigration())
    let persist = await PostgresPersistDriver(
        client: pgClient,
        migrations: migrations,
        logger: logger
    )
    
    let router = buildRouter(persist: persist, competitionRepository: compRepo, userRepository: userRepo)
    
    
    
    var app = Application(
        router: router,
        configuration: .init(
            address: .hostname(arguments.hostname, port: arguments.port),
            serverName: "voimadb-api"
        ),
        services: [pgClient, persist],
        logger: logger
    )
    app.beforeServerStarts {
        try await migrations.apply(client: pgClient, logger: logger, dryRun: false)
    }
    return app
}

