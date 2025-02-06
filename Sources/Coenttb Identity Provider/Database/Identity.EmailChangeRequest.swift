

import Dependencies
@preconcurrency import Fluent
import Foundation
import Vapor
import Fluent
import Vapor

extension Database {
    public final class EmailChangeRequest: Model, @unchecked Sendable {
        public static let schema = "email_change_requests"
        
        @ID(key: .id)
        public var id: UUID?
        
        @Parent(key: FieldKeys.identityId)
        package var identity: Database.Identity
        
        @Field(key: FieldKeys.newEmail)
        package var newEmail: String
        
        @Parent(key: FieldKeys.tokenId)
        package var token: Database.Identity.Token
        
        package enum FieldKeys {
            static let identityId: FieldKey = "identity_id"
            static let newEmail: FieldKey = "new_email"
            static let tokenId: FieldKey = "token_id"
        }
        
        public init() {}
        
        package init(
            id: UUID? = nil,
            identity: Database.Identity,
            newEmail: String,
            token: Database.Identity.Token
        ) throws {
            guard token.type == .emailChange
            else { throw Abort(.badRequest, reason: "Invalid token type for email change") }
            
            self.id = id
            self.$identity.id = try identity.requireID()
            self.newEmail = newEmail
            self.$token.id = try token.requireID()
        }
    }
}

extension Database.EmailChangeRequest {
    
    public struct Migration: AsyncMigration {
        
        public var name: String = "Coenttb_Identity.EmailChangeRequest.Migration.Create"
        
        public init(){}
        public func prepare(on database: Fluent.Database) async throws {
            try await database.schema(Database.EmailChangeRequest.schema)
                .id()
                .field(FieldKeys.identityId, .uuid, .required, .references(Database.Identity.schema, "id", onDelete: .cascade))
                .field(FieldKeys.newEmail, .string, .required)
                .field(FieldKeys.tokenId, .uuid, .required, .references(Database.Identity.Token.schema, "id", onDelete: .cascade))
                .unique(on: FieldKeys.tokenId)
                .create()
        }
        
        public func revert(on database: Fluent.Database) async throws {
            try await database.schema(Database.EmailChangeRequest.schema).delete()
        }
    }
}



