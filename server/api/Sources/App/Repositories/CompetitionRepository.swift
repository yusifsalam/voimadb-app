import Foundation


protocol CompetitionRepository: Sendable {
    /// Create competition
    func create(name: String, description: String?, date: Date, city: String, country: String) async throws -> Competition
    /// Get competiton
    func get(id: UUID) async throws -> Competition?
    /// List all competitions
    func list() async throws -> [Competition]
    /// Update competition. Returns updated competition if successful
    func update(id: UUID, name: String?, description: String?, date: Date?, city: String?, country: String?) async throws -> Competition?
    /// Delete competition. Returns true if successful
    func delete(id: UUID) async throws -> Bool
    /// Delete all competitions
    func deleteAll() async throws
}
