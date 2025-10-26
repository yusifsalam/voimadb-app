import JWT
import Vapor

/// Payload structure for Apple's Sign in with Apple identity tokens
/// Used to verify tokens received from Apple's authentication service
struct AppleIdentityToken: JWTPayload {
    // Issuer (should be "https://appleid.apple.com")
    var iss: IssuerClaim

    // Subject (Apple user ID - unique identifier for the user)
    var sub: SubjectClaim

    // Audience (your app's bundle ID)
    var aud: AudienceClaim

    // Expiration
    var exp: ExpirationClaim

    // Issued at
    var iat: IssuedAtClaim

    // Email (optional, only provided on first sign in)
    var email: String?

    // Email verified (optional)
    var email_verified: Bool?

    // Is private email (optional, true if using Apple's relay service)
    var is_private_email: Bool?

    func verify(using _: some JWTAlgorithm) async throws {
        // Verify token is not expired
        try exp.verifyNotExpired()

        // Verify issuer is Apple
        guard iss.value == "https://appleid.apple.com" else {
            throw JWTError.claimVerificationFailure(failedClaim: iss, reason: "Invalid issuer")
        }

        // Note: Audience verification (app bundle ID) should be done separately
        // in the verification function where we have access to the expected bundle ID
    }
}
