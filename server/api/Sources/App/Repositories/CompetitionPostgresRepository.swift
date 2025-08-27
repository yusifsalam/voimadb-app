import Foundation
import PostgresNIO

struct CompetitionPostgresRepository: CompetitionRepository {
    let client: PostgresClient
    let logger: Logger
    
    /// Create Competitions table
    func createTable() async throws {
        do {
            logger.info("Creating competitions table")
            try await self.client.query("""
                CREATE TABLE IF NOT EXISTS competitions (
                    "id" uuid PRIMARY KEY,
                    "name" text NOT NULL,
                    "description" text,
                    "date" timestamp NOT NULL,
                    "city" text NOT NULL,
                    "country" text NOT NULL
                )
                """,
                                        logger: logger
            )
            logger.info( "Competitions table successfully created")
        } catch {
            logger.error("PSQLError in createTable: \(String(reflecting: error))")
            throw error
        }
    }
    
    func create(name: String, description: String?, date: Date, city: String, country: String) async throws -> Competition {
        let id = UUID()
        try await self.client.query("INSERT into competitions (id, name, description, date, city, country) VALUES (\(id), \(name), \(description ?? ""), \(date), \(city), \(country));", logger: logger)
        return Competition(id: id, name: name, description: description, date: date, city: city, country: country)
    }
    
    func get(id: UUID) async throws -> Competition? {
        let stream = try await self.client.query("""
                    SELECT "id", "name", "description", "date", "city", "country" FROM competitions WHERE "id" = \(id)
                    """, logger: logger
        )
        for try await (id, name, description, date, city, country) in stream.decode((UUID, String, String?, Date, String, String).self, context: .default) {
            return Competition(id: id, name: name, description: description, date: date, city: city, country: country)
        }
        return nil
    }
    
    func list() async throws -> [Competition] {
        do {
            
            let stream = try await self.client.query("""
            SELECT "id", "name", "description", "date", "city", "country" FROM competitions
            """, logger: logger)
            var competitions: [Competition] = []
            for try await (id, name, description, date, city, country) in stream.decode((UUID, String, String?, Date, String, String).self, context: .default) {
                let competition = Competition(id: id, name: name, description: description, date: date, city: city, country: country)
                competitions.append(competition)
            }
            return competitions
        } catch {
            logger.error("Something went wrong \(String(reflecting: error))")
            throw error
        }
    }
    
    func update(id: UUID, name: String?, description: String?, date: Date?, city: String?, country: String?) async throws -> Competition? {
        var updateFields: [String] = []
        var bindings = PostgresBindings()
        var bindingIndex = 1
        
        if let name {
            updateFields.append("name = $\(bindingIndex)")
            bindings.append(name)
            bindingIndex += 1
        }
        if let description {
            updateFields.append("description = $\(bindingIndex)")
            bindings.append(description)
            bindingIndex += 1
        }
        if let date {
            updateFields.append("date = $\(bindingIndex)")
            bindings.append(date)
            bindingIndex += 1
        }
        if let city {
            updateFields.append("city = $\(bindingIndex)")
            bindings.append(city)
            bindingIndex += 1
        }
        if let country {
            updateFields.append("country = $\(bindingIndex)")
            bindings.append(country)
            bindingIndex += 1
        }
        
        // Only execute update if there are fields to update
        if !updateFields.isEmpty {
            logger.info("Updating competition with id \(id)")
            let updateSQL = """
                UPDATE competitions 
                SET \(updateFields.joined(separator: ", ")) 
                WHERE id = $\(bindingIndex)
                """
            bindings.append(id)
            
            do {
                let unsafeQuery = PostgresQuery(unsafeSQL: updateSQL, binds: bindings)
                _ = try await self.client.query(unsafeQuery, logger: self.logger)
            } catch {
                logger.error("Something went wrong \(String(reflecting: error))")
                return nil
            }
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
