import Fluent
import Vapor

struct ClubController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let clubs = routes.grouped("api", "clubs")
        clubs.get(use: index)
        clubs.get(":clubID", use: show)
    }

    func index(req: Request) async throws -> [Club] {
        try await Club.query(on: req.db).all()
    }

    func show(req: Request) async throws -> Club {
        guard let club = try await Club.find(req.parameters.get("clubID"), on: req.db) else {
            throw Abort(.notFound)
        }
        return club
    }
}
