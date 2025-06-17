//
//  NotFoundMiddleware.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 01. 23..
//

import Hummingbird

struct NotFoundMiddleware<Context: RequestContext>: RouterMiddleware {
    func handle(
        _ request: Request,
        context: Context,
        next: (
            Request,
            Context
        ) async throws -> Response
    ) async throws -> Response {
        do {
            return try await next(request, context)
        }
        catch let error as HTTPError {
            if error.status == .notFound {
                return Response(
                    status: .seeOther,
                    headers: [
                        .location: "/404.html"
                    ]
                )
            }
            throw error
        }
    }
}
