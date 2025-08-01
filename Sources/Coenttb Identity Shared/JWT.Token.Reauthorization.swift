import Dependencies
import Foundation
import JWT
import Swift_Web
import Vapor

extension Swift_Web.JWT.Token {
    public struct Reauthorization: Codable, Sendable {
        // Required Standard JWT Claims
        public var expiration: ExpirationClaim
        public var issuedAt: IssuedAtClaim
        public var subject: SubjectClaim
        public var issuer: IssuerClaim?
        public var audience: AudienceClaim?
        public var tokenId: IDClaim

        // Optional Standard Claims
        public var notBefore: NotBeforeClaim?

        // Required Custom Claims
        public var identityId: UUID
        public var email: String
        public var sessionVersion: Int

        package init(
            expiration: ExpirationClaim,
            issuedAt: IssuedAtClaim,
            subject: SubjectClaim,
            issuer: IssuerClaim?,
            audience: AudienceClaim? = nil,
            tokenId: IDClaim,
            notBefore: NotBeforeClaim? = nil,
            identityId: UUID,
            email: String,
            sessionVersion: Int
        ) {
            self.expiration = expiration
            self.issuedAt = issuedAt
            self.subject = subject
            self.issuer = issuer
            self.audience = audience
            self.tokenId = tokenId
            self.notBefore = notBefore
            self.identityId = identityId
            self.email = email
            self.sessionVersion = sessionVersion
        }

        enum CodingKeys: String, CodingKey {
            case expiration = "exp"
            case issuedAt = "iat"
            case subject = "sub"
            case issuer = "iss"
            case audience = "aud"
            case notBefore = "nbf"
            case tokenId = "jti"
            case identityId = "iid"
            case email = "eml"
            case sessionVersion = "sev"
        }
    }
}

extension Swift_Web.JWT.Token.Reauthorization: JWTPayload {
    public func verify(using algorithm: some JWTKit.JWTAlgorithm) async throws {
        @Dependency(\.date) var date
        try self.expiration.verifyNotExpired(currentDate: date())
//        try self.notBefore?.verifyNotBefore()
        // Verify email is present
        guard !self.email.isEmpty else {
            throw JWTError.claimVerificationFailure(
                failedClaim: self.expiration,
                reason: "email cannot be empty"
            )
        }

//        // Verify identityId matches between tokens
//        guard self.identityId == refreshToken.identityId else {
//            throw JWTError.claimVerificationFailure(
//                failedClaim: nil,
//                reason: "identity mismatch between tokens"
//            )
//        }
    }
}
