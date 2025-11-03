import Fluent
import Vapor

struct LifterController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let lifters = routes.grouped("api", "lifters")
        lifters.get(use: index)
        lifters.get(":lifterID", use: show)
    }

    func index(req: Request) async throws -> [Lifter] {
        try await Lifter.query(on: req.db).all()
    }

    func show(req: Request) async throws -> Lifter {
        guard let lifter = try await Lifter.find(req.parameters.get("lifterID"), on: req.db) else {
            throw Abort(.notFound)
        }
        return lifter
    }
}
