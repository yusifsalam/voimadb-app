import Fluent
import Vapor

final class User: Model, Content, @unchecked Sendable {
    static let schema = "users"

    @ID(custom: .id, generatedBy: .database)
    var id: UUID?
    
    @Field(key: "name")
    var name: String

    @Field(key: "email")
    var email: String

    @Field(key: "password_hash")
    var passwordHash: String

    @OptionalField(key: "apple_user_id")
    var appleUserId: String?

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    init() {}

    init(id: UUID? = nil, name: String, email: String, passwordHash: String,  appleUserId: String? = nil) {
        self.id = id
        self.name = name
        self.email = email
        self.passwordHash = passwordHash
        self.appleUserId = appleUserId
    }

}

extension User {
    struct Create: Content {
        var name: String
        var email: String
        var password: String
        var confirmPassword: String
    }
}

extension User.Create: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("name", as: String.self, is: !.empty)
        validations.add("email", as: String.self, is: .email)
        validations.add("password", as: String.self, is: .count(8...))
    }
}


extension User {
    func generateToken() throws -> UserToken {
        try .init(
            userID: self.requireID(),
            value: [UInt8].random(count: 32).base64
            
        )
    }
}

extension User: ModelAuthenticatable {
    static var usernameKey: KeyPath<User, FluentKit.FieldProperty<User, String>> { \.$email }
    
    static var passwordHashKey: KeyPath<User, FluentKit.FieldProperty<User, String>> { \.$passwordHash }
    

    func verify(password: String) throws -> Bool {
        try Bcrypt.verify(password, created: passwordHash)
    }
}
