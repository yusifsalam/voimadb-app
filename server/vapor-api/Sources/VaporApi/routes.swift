import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get { _ async in
        "VoimaDB API is running! Current time is \(Date())"
    }

    // Lifter routes
    app.group("api", "lifters") { lifters in
        lifters.get { req async throws -> [Lifter] in
            return try await Lifter.query(on: req.db).all()
        }

        lifters.get(":lifterID") { req async throws -> Lifter in
            guard let lifter = try await Lifter.find(req.parameters.get("lifterID"), on: req.db) else {
                throw Abort(.notFound)
            }
            return lifter
        }
    }

    // Competition routes
    app.group("api", "competitions") { competitions in
        competitions.get { req async throws -> [Competition] in
            return try await Competition.query(on: req.db).all()
        }

        competitions.get(":competitionID") { req async throws -> Competition in
            guard let competition = try await Competition.find(req.parameters.get("competitionID"), on: req.db) else {
                throw Abort(.notFound)
            }
            return competition
        }

        competitions.get(":competitionID", "results") { req async throws -> [Result] in
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

    // Club routes
    app.group("api", "clubs") { clubs in
        clubs.get { req async throws -> [Club] in
            return try await Club.query(on: req.db).all()
        }

        clubs.get(":clubID") { req async throws -> Club in
            guard let club = try await Club.find(req.parameters.get("clubID"), on: req.db) else {
                throw Abort(.notFound)
            }
            return club
        }
    }

    // Result routes
    app.group("api", "results") { results in
        results.get { req async throws -> [Result] in
            return try await Result.query(on: req.db)
                .with(\.$lifter)
                .with(\.$competition)
                .with(\.$club)
                .all()
        }

        results.get(":resultID") { req async throws -> Result in
            guard let result = try await Result.find(req.parameters.get("resultID"), on: req.db) else {
                throw Abort(.notFound)
            }
            try await result.$lifter.load(on: req.db)
            try await result.$competition.load(on: req.db)
            try await result.$club.load(on: req.db)
            return result
        }
    }

    // Weight class routes
    app.group("api", "weightclasses") { weightClasses in
        weightClasses.get { req async throws -> [WeightClass] in
            return try await WeightClass.query(on: req.db).all()
        }
    }

    // Age class routes
    app.group("api", "ageclasses") { ageClasses in
        ageClasses.get { req async throws -> [AgeClass] in
            return try await AgeClass.query(on: req.db).all()
        }
    }
    
    
    app.post("users") { req async throws -> User in
        try User.Create.validate(content: req)
        let create = try req.content.decode(User.Create.self)
        guard create.password == create.confirmPassword else {
            throw Abort(.badRequest, reason: "Passwords did not match")
        }
        let user = try User(
            name: create.name,
            email: create.email,
            passwordHash: Bcrypt.hash(create.password)
        )
        try await user.save(on: req.db)
        return user
    }
    
    let passwordProtected = app.grouped(User.authenticator())
    passwordProtected.post("login") { req async throws -> UserToken in
        let user = try req.auth.require(User.self)
        let token = try user.generateToken()
        try await token.save(on: req.db)
        return token
    }
    
    let tokenProtected = app.grouped(UserToken.authenticator())
    tokenProtected.get("me") { req -> User in
        try req.auth.require(User.self)
    }
}
