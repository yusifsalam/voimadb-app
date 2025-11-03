import Fluent
import Vapor

struct ResultController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let results = routes.grouped("api", "results")
        results.get(use: index)
        results.get(":resultID", use: show)
    }

    func index(req: Request) async throws -> [Result] {
        try await Result.query(on: req.db)
            .with(\.$lifter)
            .with(\.$competition)
            .with(\.$club)
            .all()
    }

    func show(req: Request) async throws -> Result {
        guard let result = try await Result.find(req.parameters.get("resultID"), on: req.db) else {
            throw Abort(.notFound)
        }
        try await result.$lifter.load(on: req.db)
        try await result.$competition.load(on: req.db)
        try await result.$club.load(on: req.db)
        return result
    }
}
