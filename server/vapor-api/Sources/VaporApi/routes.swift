import Vapor
import Fluent

func routes(_ app: Application) throws {
    app.get { req async in
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
}
