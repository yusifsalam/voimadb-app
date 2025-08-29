import Foundation
import Hummingbird
import HummingbirdAuth
import HummingbirdBasicAuth
import HummingbirdBcrypt

struct AuthController {
    typealias Context = AppRequestContext
    let repository: UserRepository
    
    func addRoutes(to group: RouterGroup<Context>) {
        group.group("register")
            .post(use: self.create)
        group.group("login")
            .add(
                middleware: BasicAuthenticator { username, _ in
                    try await repository.findByEmail(username)
                }
            )
            .post(use: self.login)
        group.group("me")
            .add(
                middleware: SessionAuthenticator { id, context in
                    try await repository.findByID(id)
                }
            )
            .get(use: self.current)
    }
    
    /// Create new user
    @Sendable func create(_ request: Request, context: Context) async throws -> UserResponse {
        do {
            
            let createUser = try await request.decode(as: CreateUserRequest.self, context: context)
            // check if user exists and if they don't then add new user
            let existingUser = try await repository.findByEmail(createUser.email)
            // if user already exist throw conflict
            guard existingUser == nil else { throw HTTPError(.conflict) }
            
            let userWithoutId = try await User(from: createUser)
            let user = try await repository.create(userWithoutId)
            
            return try UserResponse(from: user)
        } catch {
            context.logger.error("Something went wrong, error: \(String(reflecting: error))")
            throw error
        }
    }
    
    /// Login user and create session
    @Sendable func login(_ request: Request, context: Context) async throws -> HTTPResponse.Status {
        // get authenticated user and return
        guard let user = context.identity else { throw HTTPError(.unauthorized) }
        // create session
        try context.sessions.setSession(user.requireID())
        return .ok
    }
    
    /// Get current logged in user
    @Sendable func current(_ request: Request, context: Context) throws -> UserResponse {
        // get authenticated user and return
        let user = try context.requireIdentity()
        return try UserResponse(id: user.requireID(), name: user.name, email: user.email)
    }
    
}
