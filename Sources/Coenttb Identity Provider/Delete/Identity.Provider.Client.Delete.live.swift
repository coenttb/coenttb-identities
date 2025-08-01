//
//  File.swift
//  coenttb-identities
//
//  Created by Coen ten Thije Boonkkamp on 01/02/2025.
//

import Coenttb_Server
import Coenttb_Web
import Fluent
import Identities
import Vapor

extension Identity.Provider.Client.Delete {
    package static func live(
        sendDeletionRequestNotification: @escaping @Sendable (_ email: EmailAddress) async throws -> Void,
        sendDeletionConfirmationNotification: @escaping @Sendable (_ email: EmailAddress) async throws -> Void
    ) -> Self {
        @Dependency(\.database) var database
        @Dependency(\.logger) var logger

        return .init(
            request: { reauthToken in
                let identity = try await Database.Identity.get(by: .auth, on: database)

                try await database.transaction { database in
                    @Dependency(\.date) var date
                    guard
                        let id = identity.id,
                        let token = try await Database.Identity.Token.query(on: database)
                        .filter(\.$identity.$id == id)
                        .filter(\.$type == .reauthenticationToken)
                        .filter(\.$value == reauthToken)
                        .filter(\.$validUntil > date())
                        .first()
                    else { throw Abort(.unauthorized, reason: "Invalid reauthorization token") }

                    try await token.delete(on: database)

                    guard identity.deletion?.state == nil
                    else { throw Abort(.badRequest, reason: "User is already pending deletion") }

                    let deletion: Database.Identity.Deletion = try .init(identity: identity)

                    deletion.state = .pending
                    deletion.requestedAt = date()
                    try await deletion.save(on: database)
                    logger.notice("Deletion requested for user \(String(describing: identity.id))")
                }

                @Dependency(\.fireAndForget) var fireAndForget
                await fireAndForget {
                    try await sendDeletionRequestNotification(identity.emailAddress)
                }
            },
            cancel: {
                let identity = try await Database.Identity.get(by: .auth, on: database)

                try await database.transaction { database in

                    guard identity.deletion?.state == .pending
                    else { throw Abort(.badRequest, reason: "User is not pending deletion") }

                    identity.deletion?.state = nil
                    identity.deletion?.requestedAt = nil

                    try await identity.save(on: database)
                    logger.notice("Deletion cancelled for user \(String(describing: identity.id))")
                }
            },
            confirm: {
                let identity = try await Database.Identity.get(by: .auth, on: database)

                try await database.transaction { database in
                    guard
                        let deletion = identity.deletion,
                        deletion.state == .pending,
                        let deletionRequestedAt = deletion.requestedAt

                    else { throw Abort(.badRequest, reason: "User is not pending deletion") }

                    // Check grace period
                    let gracePeriod: TimeInterval = 7 * 24 * 60 * 60 // 7 days

                    @Dependency(\.date) var date

                    guard date().timeIntervalSince(deletionRequestedAt) >= gracePeriod
                    else { throw Abort(.badRequest, reason: "Grace period has not yet expired") }

                    // Update user state
                    identity.deletion?.state = .deleted
                    try await identity.save(on: database)

                    logger.notice("Identity \(String(describing: identity.id)) marked as deleted")
                }

                @Dependency(\.fireAndForget) var fireAndForget
                await fireAndForget {
                    try await sendDeletionConfirmationNotification(identity.emailAddress)
                }
            }
        )
    }
}
