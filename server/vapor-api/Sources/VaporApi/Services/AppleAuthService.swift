import JWT
import JWTKit
import Vapor

/// Service for handling Apple Sign In authentication
/// Fetches Apple's public keys and verifies identity tokens
struct AppleAuthService {
    let app: Application
    let client: any Client
    let logger: Logger

    // Apple's public keys endpoint
    private let appleKeysURL = "https://appleid.apple.com/auth/keys"

    // Response structure from Apple's keys endpoint
    struct ApplePublicKeys: Codable {
        let keys: [JWK]

        struct JWK: Codable {
            let kty: String  // Key type (should be "RSA")
            let kid: String  // Key ID
            let use: String  // Usage (should be "sig" for signature)
            let alg: String  // Algorithm (should be "RS256")
            let n: String    // RSA modulus
            let e: String    // RSA exponent
        }
    }

    /// Fetch Apple's public keys for JWT verification
    /// - Returns: Array of JWK (JSON Web Keys) from Apple
    func fetchApplePublicKeys() async throws -> ApplePublicKeys {
        logger.info("Fetching Apple's public keys from \(appleKeysURL)")

        let response = try await client.get(URI(string: appleKeysURL))

        guard response.status == .ok else {
            logger.error("Failed to fetch Apple's public keys. Status: \(response.status)")
            throw Abort(.internalServerError, reason: "Failed to fetch Apple's public keys")
        }

        let keys = try response.content.decode(ApplePublicKeys.self)
        logger.info("Successfully fetched \(keys.keys.count) Apple public keys")

        return keys
    }

    /// Verify Apple's identity token and extract user information
    /// - Parameters:
    ///   - identityToken: JWT token from Apple Sign In
    ///   - expectedAudience: Your app's bundle ID (e.g., "com.yourcompany.voimadb")
    /// - Returns: Verified AppleIdentityToken payload
    func verifyIdentityToken(_ identityToken: String, expectedAudience: String) async throws -> AppleIdentityToken {
        logger.info("Verifying Apple identity token")

        // Fetch Apple's public keys
        let appleKeys = try await fetchApplePublicKeys()

        // Parse the token header to get the key ID (kid)
        let tokenParts = identityToken.split(separator: ".")
        guard tokenParts.count == 3 else {
            throw Abort(.badRequest, reason: "Invalid JWT format")
        }

        // Decode the header to get the key ID
        guard let headerData = Data(base64URLEncoded: String(tokenParts[0])) else {
            throw Abort(.badRequest, reason: "Invalid JWT header encoding")
        }

        struct JWTHeader: Codable {
            let kid: String
            let alg: String
        }

        let header = try JSONDecoder().decode(JWTHeader.self, from: headerData)
        logger.info("Token header - kid: \(header.kid), alg: \(header.alg)")

        // Find the matching public key
        guard let matchingKey = appleKeys.keys.first(where: { $0.kid == header.kid }) else {
            logger.error("No matching public key found for kid: \(header.kid)")
            throw Abort(.unauthorized, reason: "Invalid token signature: key not found")
        }

        // Verify that the key is RSA with RS256
        guard matchingKey.kty == "RSA", matchingKey.alg == "RS256" else {
            throw Abort(.unauthorized, reason: "Unsupported key type or algorithm")
        }

        // Create a temporary key collection with Apple's public key
        // Apple uses RS256 (RSA with SHA-256)
        let keyCollection = try await JWTKeyCollection()
            .add(
                rsa: JWTKit.Insecure.RSA.PublicKey(
                    modulus: matchingKey.n,
                    exponent: matchingKey.e
                ),
                digestAlgorithm: .sha256,
                kid: JWTKit.JWKIdentifier(string: header.kid)
            )

        // Verify and decode the token
        let payload = try await keyCollection.verify(
            identityToken,
            as: AppleIdentityToken.self
        )

        // Verify the audience matches our app's bundle ID
        guard payload.aud.value.contains(expectedAudience) else {
            logger.error("Audience mismatch: expected '\(expectedAudience)', got '\(payload.aud.value)'")
            throw Abort(.unauthorized, reason: "Token audience does not match app bundle ID")
        }

        logger.info("Successfully verified Apple identity token for user: \(payload.sub.value)")

        return payload
    }
}

// Extension to decode base64URL encoded strings
extension Data {
    init?(base64URLEncoded string: String) {
        // Convert base64url to base64
        var base64 = string
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")

        // Add padding if needed
        let remainder = base64.count % 4
        if remainder > 0 {
            base64 += String(repeating: "=", count: 4 - remainder)
        }

        self.init(base64Encoded: base64)
    }
}
