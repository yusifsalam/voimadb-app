import Hummingbird
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
typealias AppRequestContext = BasicRequestContext

///  Build application
/// - Parameter arguments: application arguments
public func buildApplication(_ arguments: some AppArguments) async throws -> some ApplicationProtocol {
    let environment = Environment()
    let logger = {
        var logger = Logger(label: "voimadb-api")
        logger.logLevel =
        arguments.logLevel ??
        environment.get("LOG_LEVEL").flatMap { Logger.Level(rawValue: $0) } ??
            .info
        return logger
    }()
    var postgresRepository: CompetitionPostgresRepository?
    let router: Router<AppRequestContext>
    if !arguments.inMemoryTesting {
        let client = PostgresClient(
            configuration: .init(host: "localhost", username: "postgres", password: "postgres", database: "postgres", tls: .disable),
            backgroundLogger: logger
        )
        let repository = CompetitionPostgresRepository(client: client, logger: logger)
        postgresRepository = repository
        router = buildRouter(repository)
        
    } else {
        router = buildRouter(CompetitionMemoryRepository())
    }
    var app = Application(
        router: router,
        configuration: .init(
            address: .hostname(arguments.hostname, port: arguments.port),
            serverName: "voimadb-api"
        ),
        logger: logger
    )
    if let postgresRepository {
        app.addServices(postgresRepository.client)
        app.beforeServerStarts {
            try await postgresRepository.createTable()
        }
    }
    return app
}

/// Build router
func buildRouter(_ repository: some CompetitionRepository) -> Router<AppRequestContext> {
    let router = Router(context: AppRequestContext.self)
    // Add middleware
    router.addMiddleware {
        // logging middleware
        LogRequestsMiddleware(.info)
    }
    router.get("/health") { _, _ -> HTTPResponse.Status in
        return .ok
    }
    router.get("/") { _,_ in
        return "Hello!"
    }
    router.addRoutes(CompetitionController(repository: repository).endpoints, atPath: "/competitions")
    return router
}
