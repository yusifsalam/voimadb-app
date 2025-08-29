import Foundation
import Hummingbird
import HummingbirdPostgres
import HummingbirdAuth

/// Build router
func buildRouter(persist: PostgresPersistDriver, competitionRepository: some CompetitionRepository, userRepository: some UserRepository) -> Router<AppRequestContext> {
    let router = Router(context: AppRequestContext.self)
    router.addMiddleware {
        LogRequestsMiddleware(.info)
        SessionMiddleware(storage: persist)
    }
    router.get("/health") { _, _ -> HTTPResponse.Status in
        return .ok
    }
    router.get("/") { _,_ in
        return "Hello!"
    }
    router.addRoutes(CompetitionController(repository: competitionRepository, authRepo: userRepository).endpoints, atPath: "/competitions")
    let userController = AuthController(repository: userRepository)
    userController.addRoutes(to: router.group("auth"))
    return router
}
