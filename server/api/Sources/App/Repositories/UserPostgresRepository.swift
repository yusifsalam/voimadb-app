import Foundation
import PostgresNIO
import HummingbirdBcrypt

struct UserPostgresRepository: UserRepository {
    let client: PostgresClient
    let logger: Logger
    
    func createTable() async throws {
        do {
            logger.info("Creating users table")
            try await self.client.query("""
                CREATE TABLE IF NOT EXISTS users (
                    "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
                    "name" TEXT NOT NULL UNIQUE,
                    "email" TEXT NOT NULL UNIQUE,
                    "password_hash" TEXT NOT NULL,
                    "created_at" TIMESTAMP NOT NULL DEFAULT NOW()
                )
                """,
                                        logger: logger
            )
            logger.info("Users table successfully created")
        } catch {
            logger.error("PSQLError in createTable: \(String(reflecting: error))")
            throw error
        }
    }
    
    func create(_ user: User) async throws -> User {
        do {
            
            let stream = try await self.client.query("""
            INSERT INTO users (name, email, password_hash) 
            VALUES (\(user.name), \(user.email), \(user.passwordHash)) 
            RETURNING id, created_at
            """, logger: logger)
            
            for try await (id, createdAt) in stream.decode((UUID, Date).self, context: .default) {
                return User(id: id, name: user.name, email: user.email, passwordHash: user.passwordHash ?? "")
            }
            
            throw PostgresError.protocol("Failed to create user: no ID returned from database")
        } catch {
            logger.error("PSQLError in create: \(String(reflecting: error))")
            throw error
        }
    }
    
    func findByName(_ name: String) async throws -> User? {
        let stream = try await self.client.query("""
            SELECT "id", "name", "email", "password_hash" FROM users WHERE "name" = \(name)
            """, logger: logger)
        
        for try await (id, name, email, passwordHash) in stream.decode((UUID, String, String, String).self, context: .default) {
            return User(id: id, name: name, email: email, passwordHash: passwordHash)
        }
        return nil
    }
    
    func findByID(_ id: UUID) async throws -> User? {
        let stream = try await self.client.query("""
            SELECT "id", "name", "email", "password_hash" FROM users WHERE "id" = \(id)
            """, logger: logger)
        
        for try await (id, name, email, passwordHash) in stream.decode((UUID, String, String, String).self, context: .default) {
            return User(id: id, name: name, email: email, passwordHash: passwordHash)
        }
        return nil
    }
    
    func findByEmail(_ email: String) async throws -> User? {
        let stream = try await self.client.query("""
            SELECT "id", "name", "email", "password_hash" FROM users WHERE "email" = \(email)
            """, logger: logger)
        
        for try await (id, name, email, passwordHash) in stream.decode((UUID, String, String, String).self, context: .default) {
            return User(id: id, name: name, email: email, passwordHash: passwordHash)
        }
        return nil
    }
    
    func update(_ user: User) async throws -> User? {
        guard let id = user.id else { return nil }
        
        let stream = try await self.client.query("""
            UPDATE users 
            SET name = \(user.name), email = \(user.email), password_hash = \(user.passwordHash)
            WHERE id = \(id)
            RETURNING id, name, email, password_hash
            """, logger: logger)
        
        for try await (id, name, email, passwordHash) in stream.decode((UUID, String, String, String).self, context: .default) {
            return User(id: id, name: name, email: email, passwordHash: passwordHash)
        }
        return nil
    }
    
    func delete(id: UUID) async throws -> Bool {
        let selectStream = try await self.client.query("""
            SELECT "id" FROM users WHERE id = \(id)
            """, logger: logger)
        
        if try await selectStream.decode(UUID.self, context: .default).first(where: { _ in true }) == nil {
            return false
        }
        
        _ = try await self.client.query("DELETE FROM users WHERE id = \(id);", logger: logger)
        return true
    }
    
    static func hashPassword(_ password: String) async throws -> String {
        return try await Bcrypt.hash(password, cost: 12)
    }
    
    static func verifyPassword(_ password: String, hash: String) async throws -> Bool {
        return try await Bcrypt.verify(password, hash: hash)
    }
}
