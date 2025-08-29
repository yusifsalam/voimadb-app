import Foundation


/// Concrete implementation of `CompetitionRepository` that stores everything in memory
actor CompetitionMemoryRepository: CompetitionRepository {
    var competitions: [Int: Competition]
    var nextId: Int


    init() {
        self.competitions = [:]
        self.nextId = 1
    }


    /// Create competition.
    func create(name: String, description: String?, date: Date, city: String, country: String) async throws -> Competition {
        let id = self.nextId
        self.nextId += 1
        let competition = Competition(id: id, name: name, description: description, date: date, city: city, country: country)
        self.competitions[id] = competition
        return competition
    }
    /// Get competition
    func get(id: Int) async throws -> Competition? {
        return self.competitions[id]
    }
    /// List all competitions
    func list() async throws -> [Competition] {
        return self.competitions.values.map { $0 }
    }
    /// Update competition. Returns updated competition if successful
    func update(id: Int, name: String?, description: String?, date: Date?, city: String?, country: String?) async throws -> Competition? {
        if var competition = self.competitions[id] {
            if let name {
                competition.name = name
            }
            if let description {
                competition.description = description
            }
            if let date {
                competition.date = date
            }
            if let city {
                competition.city = city
            }
            if let country {
                competition.country = country
            }
            self.competitions[id] = competition
            return competition
        }
        return nil
    }
    /// Delete competition. Returns true if successful
    func delete(id: Int) async throws -> Bool {
        if self.competitions[id] != nil {
            self.competitions[id] = nil
            return true
        }
        return false
    }
    /// Delete all competitions
    func deleteAll() async throws {
        self.competitions = [:]
    }


}
