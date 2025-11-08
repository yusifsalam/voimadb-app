import Vapor
import VoimaDBShared

extension UserResponse: @retroactive Content {}
extension UserTokenResponse: @retroactive Content {}
extension ErrorResponse: @retroactive Content {}
extension UserRegistrationRequest: @retroactive Content {}
extension AppleSignInRequest: @retroactive Content {}
