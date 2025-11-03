import Fluent
import Vapor

struct AgeClassController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let ageClasses = routes.grouped("api", "ageclasses")
        ageClasses.get(use: index)
    }

    func index(req: Request) async throws -> [AgeClass] {
        try await AgeClass.query(on: req.db).all()
    }
}
