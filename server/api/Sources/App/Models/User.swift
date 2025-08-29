import Foundation
import Hummingbird
import HummingbirdAuth
import HummingbirdBasicAuth
import HummingbirdBcrypt
import NIOPosix

struct User: PasswordAuthenticatable {
    
    var id: UUID?
    var name: String
    var email: String
    var passwordHash: String?
    
    
    init(id: UUID? = nil, name: String, email: String, passwordHash: String) {
        self.id = id
        self.name = name
        self.email = email
        self.passwordHash = passwordHash
    }
    
    init(from userRequest: CreateUserRequest) async throws {
        self.id = nil
        self.name = userRequest.name
        self.email = userRequest.email
        
        // Do Bcrypt hash on a separate thread to not block the general task executor
        self.passwordHash = try await NIOThreadPool.singleton.runIfActive { Bcrypt.hash(userRequest.password, cost: 12) }
    }
}

extension User: ResponseEncodable, Decodable, Equatable {}

enum UserError: Error {
    case runtimeError(String)
}

extension User {
    var username: String { self.email }
    
    public func requireID() throws -> UUID {
        guard let id = self.id else {
            throw UserError.runtimeError("ID is required!")
        }
        return id
    }
}


/// Create user request object decoded from HTTP body
struct CreateUserRequest: Codable {
    let name: String
    let email: String
    let password: String
    
    init(name: String, email: String, password: String) {
        self.name = name
        self.email = email
        self.password = password
    }
}

/// User encoded into HTTP response
struct UserResponse: ResponseCodable {
    let id: UUID
    let name: String
    let email: String
    
    init(id: UUID, name: String, email: String) {
        self.id = id
        self.name = name
        self.email = email
    }
    
    init(from user: User) throws {
        self.id = try user.requireID()
        self.name = user.name
        self.email = user.email
    }
}
