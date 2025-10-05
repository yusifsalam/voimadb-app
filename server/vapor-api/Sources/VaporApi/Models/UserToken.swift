import Fluent
import Vapor

final class UserToken: Model, Content, ModelTokenAuthenticatable, @unchecked Sendable {
    typealias User = VaporApi.User
    static let schema = "user_tokens"
    
    static var valueKey: KeyPath<UserToken, Field<String>> { \.$value }
    static var userKey: KeyPath<UserToken, Parent<User>> { \.$user }
    
    var isValid: Bool {
        return self.expiresAt > Date() && !self.isRevoked
    }
    
    
    @ID(custom: .id, generatedBy: .database)
    var id: UUID?
    
    @Parent(key: "user_id")
    var user: User
    
    @Field(key: "value")
    var value: String
    
    @Field(key: "is_revoked")
    var isRevoked: Bool
    
    @Field(key: "expires_at")
    var expiresAt: Date
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    init() {}
    
    init(id: UUID? = nil, userID: User.IDValue, value: String) {
        self.id = id
        self.$user.id = userID
        self.value = value
        self.expiresAt = Date().advanced(by: 60 * 60 * 24 * 30)
        self.isRevoked = false
    }
    
}
