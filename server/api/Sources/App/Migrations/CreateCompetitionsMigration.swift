import PostgresMigrations
import PostgresNIO

struct CreateCompetitionsTableMigration: DatabaseMigration {
    func apply(connection: PostgresConnection, logger: Logger) async throws {
        logger.info("Creating competitions table...")
        try await connection.query(
            """
                            CREATE TABLE IF NOT EXISTS competitions (
                                                "id" SERIAL PRIMARY KEY,
                                                "name" text NOT NULL,
                                                "description" text,
                                                "date" timestamp NOT NULL,
                                                "city" text NOT NULL,
                                                "country" text NOT NULL
            )
            """,
            logger: logger
        )
        logger.info("Competitons table created successfully.")
    }
    
    
    func revert(connection: PostgresConnection, logger: Logger) async throws {
        try await connection.query(
            "DROP TABLE users",
            logger: logger
        )
    }
}
