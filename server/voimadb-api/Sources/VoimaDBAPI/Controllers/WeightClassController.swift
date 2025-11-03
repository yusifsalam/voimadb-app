import Fluent
import Vapor

struct WeightClassController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let weightClasses = routes.grouped("api", "weightclasses")
        weightClasses.get(use: index)
    }

    func index(req: Request) async throws -> [WeightClass] {
        try await WeightClass.query(on: req.db).all()
    }
}
