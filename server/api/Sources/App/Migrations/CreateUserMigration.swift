import PostgresMigrations
import PostgresNIO

struct CreateUsersTableMigration: DatabaseMigration {
    func apply(connection: PostgresConnection, logger: Logger) async throws {
        try await connection.query(
            """
                            CREATE TABLE IF NOT EXISTS users (
                                "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
                                "name" TEXT NOT NULL,
                                "email" TEXT NOT NULL UNIQUE,
                                "password_hash" TEXT NOT NULL,
                                "created_at" TIMESTAMP NOT NULL DEFAULT NOW()
                            )
            """,
            logger: logger
        )
    }
    
    
    func revert(connection: PostgresConnection, logger: Logger) async throws {
        try await connection.query(
            "DROP TABLE users",
            logger: logger
        )
    }
}
