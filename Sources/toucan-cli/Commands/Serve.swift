import Foundation
import ArgumentParser
import ToucanSDK
import Hummingbird
import Logging

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

extension Entrypoint {

    struct Serve: AsyncParsableCommand {

        static var _commandName: String = "serve"

        @Argument(help: "The root directory (default: docs).")
        var root: String = "./docs"

        @Option(name: .shortAndLong)
        var hostname: String = "127.0.0.1"

        @Option(name: .shortAndLong)
        var port: Int = 3000

        @Option(name: .shortAndLong, help: "The log level to use.")
        var logLevel: Logger.Level = .info

        func run() async throws {
            let home = FileManager.default.homeDirectoryForCurrentUser.path
            var rootPath = root.replacingOccurrences(of: "~", with: home)
            if rootPath.hasPrefix(".") {
                rootPath =
                    FileManager.default.currentDirectoryPath + "/" + rootPath
            }

            let router = Router()
            var logger = Logger(label: "toucan-server")
            logger.logLevel = logLevel

            router.addMiddleware {
                NotFoundMiddleware()
                FileMiddleware(
                    rootPath,
                    searchForIndexHtml: true,
                    logger: logger
                )
            }

            let app = Application(
                router: router,
                configuration: .init(
                    address: .hostname(hostname, port: port),
                    serverName: "toucan-server"
                ),
                logger: logger
            )
            try await app.runService()
        }
    }
}
