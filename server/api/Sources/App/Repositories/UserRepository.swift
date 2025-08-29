import Foundation
import Hummingbird

protocol UserRepository: Sendable {
    func create(_ user: User) async throws -> User
    func findByName(_ name: String) async throws -> User?
    func findByID(_ id: UUID) async throws -> User?
    func findByEmail(_ email: String) async throws -> User?
    func update(_ user: User) async throws -> User?
    func delete(id: UUID) async throws -> Bool
}

struct UserCreateRequest: Codable, Sendable {
    let name: String
    let email: String
    let password: String
}

struct UserLoginRequest: Codable, Sendable {
    let name: String
    let password: String
}