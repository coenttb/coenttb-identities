//
//  File.swift
//  coenttb-web
//
//  Created by Coen ten Thije Boonkkamp on 10/09/2024.
//

import Coenttb_Vapor
import Coenttb_Web
import Foundation
import Identities

extension Identity.Provider.API {
    public static func response(
        api: Identity.Provider.API
    ) async throws -> Response {
        
        let rateLimitClient = try await Identity.API.rateLimit(api: api)

        do {
            try Identity.API.protect(api: api, with: Database.Identity.self)
        } catch {
            throw Abort(.unauthorized)
        }
        
        @Dependency(\.identity.provider.client) var client
        
        switch api {
        case .authenticate(let authenticate):
            do {
                let response = try await Identity.Provider.API.Authenticate.response(authenticate: authenticate)
                await rateLimitClient.recordSuccess()
                return response
            } catch {
                await rateLimitClient.recordFailure()
                throw error
            }

        case .create(let create):
            do {
                let response = try await Identity.Provider.API.Create.response(create: create)
                await rateLimitClient.recordSuccess()
                return response
            } catch {
                await rateLimitClient.recordFailure()
                throw error
            }

        case .delete(let delete):
            do {
                let response = try await Identity.Provider.API.Delete.response(delete: delete)
                await rateLimitClient.recordSuccess()
                return response
            } catch {
                await rateLimitClient.recordFailure()
                throw error
            }

        case .logout:
            try await client.logout()
            return Response.success(true)

        case let .password(password):
            do {
                let response = try await Identity.Provider.API.Password.response(password: password)
                await rateLimitClient.recordSuccess()
                return response
            } catch {
                await rateLimitClient.recordFailure()
                throw error
            }

        case let .email(email):
            do {
                let response = try await Identity.Provider.API.Email.response(email: email)
                await rateLimitClient.recordSuccess()
                return response
            } catch {
                await rateLimitClient.recordFailure()
                throw error
            }

        case .reauthorize(let reauthorize):
            let data = try await client.reauthorize(password: reauthorize.password)
            return Response.success(true, data: data)
        }
    }
}
