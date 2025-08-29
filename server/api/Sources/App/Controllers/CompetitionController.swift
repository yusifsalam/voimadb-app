import Hummingbird
import HummingbirdAuth
import Foundation

struct CompetitionController<Repository: CompetitionRepository> {
    typealias Context = AppRequestContext
    let repository: Repository
    let authRepo: UserRepository
    
    var endpoints: RouteCollection<AppRequestContext> {
        return RouteCollection(context: AppRequestContext.self)
            .add(middleware: SessionAuthenticator { id, context in
                try await authRepo.findByID(id)
            })
            .get(":id", use: get)
            .get(use: list)
            .post(use: create)
            .patch(":id", use: update)
            .delete(":id", use: delete)
            .delete(use: deleteAll)
    }
    
    @Sendable func get(request: Request, context: some RequestContext) async throws -> Competition? {
        let id = try context.parameters.require("id", as: Int.self)
        return try await self.repository.get(id: id)
    }
    
    @Sendable func list(request: Request, context: some RequestContext) async throws -> [Competition] {
        return try await self.repository.list()
    }
    
    struct CreateRequest: Decodable {
        let name: String
        let description: String?
        let date: Date
        let city: String
        let country: String
    }
    
    @Sendable func create(request: Request, context: Context) async throws -> EditedResponse<Competition> {
        _ = try context.requireIdentity()
        let request = try await request.decode(as: CreateRequest.self, context: context)
        let competition =  try await self.repository.create(name: request.name, description: request.description, date: request.date, city: request.city, country: request.country)
        return EditedResponse(status: .created, response: competition)
    }
    
    struct UpdateRequest: Decodable {
        let name: String?
        let description: String?
        let date: Date?
        let city: String?
        let country: String?
    }
    
    @Sendable func update(request: Request, context: Context) async throws -> Competition? {
        _ = try context.requireIdentity()
        let id = try context.parameters.require("id", as: Int.self)
        let request = try await request.decode(as: UpdateRequest.self, context: context)
        guard let competition = try await self.repository.update(
            id: id,
            name: request.name,
            description: request.description,
            date: request.date,
            city: request.city,
            country: request.country
        ) else {
            throw HTTPError(.badRequest)
        }
        return competition
    }
    
    @Sendable func delete(request: Request, context: Context) async throws -> HTTPResponse.Status {
        _ = try context.requireIdentity()
        let id = try context.parameters.require("id", as: Int.self)
        if try await self.repository.delete(id: id) {
            return .ok
        } else {
            return .badRequest
        }
    }
    
    @Sendable func deleteAll(request: Request, context: Context) async throws -> HTTPResponse.Status {
        _ = try context.requireIdentity()
        try await self.repository.deleteAll()
        return .ok
    }
}
