import Fluent
import Vapor
import VoimaDBShared

struct AuthController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        // User registration
        routes.post("users", use: register)

        // Password-based login
        let passwordProtected = routes.grouped(User.authenticator())
        passwordProtected.post("login", use: login)

        // Token-protected routes
        let tokenProtected = routes.grouped(UserToken.authenticator())
        tokenProtected.get("me", use: me)
        tokenProtected.post("logout", use: logout)

        // Apple Sign In
        routes.post("auth", "apple", use: appleSignIn)
    }

    func register(req: Request) async throws -> UserResponse {
        try User.Create.validate(content: req)
        let create = try req.content.decode(UserRegistrationRequest.self)
        guard create.password == create.confirmPassword else {
            throw Abort(.badRequest, reason: "Passwords did not match")
        }
        let user = try User(
            name: create.name,
            email: create.email,
            passwordHash: Bcrypt.hash(create.password)
        )
        try await user.save(on: req.db)
        return try user.toResponse()
    }

    func login(req: Request) async throws -> UserTokenResponse {
        let user = try req.auth.require(User.self)
        let token = try user.generateToken()
        try await token.save(on: req.db)
        return token.toResponse()
    }

    func me(req: Request) throws -> UserResponse {
        let user = try req.auth.require(User.self)
        return try user.toResponse()
    }

    func logout(req: Request) async throws -> HTTPStatus {
        let user = try req.auth.require(User.self)

        guard let bearerToken = req.headers.bearerAuthorization?.token else {
            throw Abort(.unauthorized, reason: "No bearer token provided")
        }

        guard let token = try await UserToken.query(on: req.db)
            .filter(\.$value == bearerToken)
            .filter(\.$user.$id == user.requireID())
            .first()
        else {
            throw Abort(.notFound, reason: "Token not found")
        }

        token.isRevoked = true
        try await token.update(on: req.db)

        req.logger.info("User \(user.email) logged out, token revoked")

        return .noContent
    }

    func appleSignIn(req: Request) async throws -> UserTokenResponse {
        let request = try req.content.decode(AppleSignInRequest.self)
        let appleToken = try await req.jwt.apple.verify(request.identityToken)

        let existingUser = try await User.query(on: req.db)
            .filter(\.$appleUserId == appleToken.subject.value)
            .first()

        let user: User
        if let existingUser = existingUser {
            user = existingUser
            req.logger.info("Existing Apple user logged in: \(appleToken.subject.value)")
        } else {
            let email = appleToken.email ?? "apple_\(appleToken.subject.value)@private.relay"
            let name = request.name ?? "Apple User"

            user = try User(
                name: name,
                email: email,
                passwordHash: Bcrypt.hash(UUID().uuidString),
                appleUserId: appleToken.subject.value
            )
            try await user.save(on: req.db)
            req.logger.info("New Apple user created: \(appleToken.subject.value)")
        }

        let token = try user.generateToken()
        try await token.save(on: req.db)

        return token.toResponse()
    }
}
