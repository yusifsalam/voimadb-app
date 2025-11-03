import Fluent
import Vapor

struct CompetitionController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let competitions = routes.grouped("api", "competitions")
        competitions.get(use: index)
        competitions.get(":competitionID", use: show)
        competitions.get(":competitionID", "results", use: results)
    }

    func index(req: Request) async throws -> [Competition] {
        try await Competition.query(on: req.db).all()
    }

    func show(req: Request) async throws -> Competition {
        guard let competition = try await Competition.find(req.parameters.get("competitionID"), on: req.db) else {
            throw Abort(.notFound)
        }
        return competition
    }

    func results(req: Request) async throws -> [Result] {
        guard let competitionID = req.parameters.get("competitionID", as: Int.self) else {
            throw Abort(.badRequest)
        }
        return try await Result.query(on: req.db)
            .filter(\.$competition.$id == competitionID)
            .with(\.$lifter)
            .with(\.$club)
            .all()
    }
}
