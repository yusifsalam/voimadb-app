import Foundation
import PostgresNIO

struct CompetitionPostgresRepository: CompetitionRepository {
    let client: PostgresClient
    let logger: Logger
    
    /// Create Competitions table
    func createTable() async throws {
        do {
            
            try await self.client.query("""
                CREATE TABLE IF NOT EXISTS competitions (
                    "id" uuid PRIMARY KEY,
                    "name" text NOT NULL,
                    "description" text,
                    "city" text NOT NULL,
                    "country" text NOT NULL
                )
                """,
                                        logger: logger
            )
        } catch {
            logger.error("PSQLError in createTable: \(String(reflecting: error))")
            throw error
        }
    }
    
    func create(name: String, description: String?, date: Date, city: String, country: String) async throws -> Competition {
        let id = UUID()
        try await self.client.query("INSERT into competitions (id, name, description, city, country) VALUES (\(id), '\(name)', '\(description ?? "")', '\(city)', '\(country)') ", logger: logger)
        return Competition(id: id, name: name, description: description, date: date, city: city, country: country)
    }
    
    func get(id: UUID) async throws -> Competition? {
        let stream = try await self.client.query("""
                    SELECT "id", "name", "description", "city", "country" FROM competitions WHERE "id" = \(id)
                    """, logger: logger
        )
        for try await (id, name, description, city, country) in stream.decode((UUID, String, String?, String, String).self, context: .default) {
            return Competition(id: id, name: name, description: description, date: Date(), city: city, country: country)
        }
        return nil
    }
    
    func list() async throws -> [Competition] {
        let stream = try await self.client.query("""
            SELECT "id", "name", "description", "city", "country" FROM competitions
            """, logger: logger)
        var competitions: [Competition] = []
        for try await (id, name, description, city, country) in stream.decode((UUID, String, String?, String, String).self, context: .default) {
            let competition = Competition(id: id, name: name, description: description, date: Date(), city: city, country: country)
            competitions.append(competition)
        }
        return competitions
    }
    
    func update(id: UUID, name: String?, description: String?, date: Date?, city: String?, country: String?) async throws -> Competition? {
        var updateFields: [String] = []
        
        if let name {
            updateFields.append("name = \(name)")
        }
        if let description {
            updateFields.append("description = \(description)")
        }
        if let date {
            updateFields.append("date = \(date)")
        }
        if let city {
            updateFields.append("city = \(city)")
        }
        if let country {
            updateFields.append("country = \(country)")
        }
        
        // Only execute update if there are fields to update
        if !updateFields.isEmpty {
            let updateQuery: PostgresQuery = """
                        UPDATE competitions 
                        SET \(updateFields.joined(separator: ", ")) 
                        WHERE id = \(id)
                        """
            _ = try await self.client.query(updateQuery, logger: self.logger)
        }
        let stream = try await self.client.query(
                    """
                    SELECT "id", "name", "description", "date", "city", "country" FROM competitions WHERE "id" = \(id)
                    """,
                    logger: self.logger
        )
        for try await(id, name, description, date, city, country) in stream.decode((UUID, String, String?, Date, String, String).self, context: .default) {
            return Competition(id: id, name: name, description: description ?? "", date: date, city: city, country: country)
        }
        return nil
    }
    
    func delete(id: UUID) async throws -> Bool {
        let selectStream = try await self.client.query(
            """
            SELECT "id" FROM competitions WHERE id = \(id)
            """, logger: logger)
        // if we didn't find the item with this id then return false
        if try await selectStream.decode(UUID.self, context: .default).first(where: { _ in true }) == nil {
            return false
        }
        _ = try await self.client.query("DELETE FROM competitions WHERE id = \(id);", logger: logger)
        return true
    }
    
    func deleteAll() async throws {
        try await self.client.query("DELETE FROM competitions;", logger: logger)
    }
    
    
}
