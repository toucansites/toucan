import ArgumentParser
import Logging
import GitVersion
import Hummingbird
import Foundation

extension Logger.Level: @retroactive ExpressibleByArgument {}

/// The main entry point for the command-line tool.
@main
struct Entrypoint: AsyncParsableCommand {

    /// Configuration for the command-line tool.
    static let configuration = CommandConfiguration(
        commandName: "toucan-serve",
        abstract: """
            Toucan serve
            """,
        discussion: """
            Serves a directory over a local web-server.
            """,
        version: "1.0.0-beta.2",
        subcommands: []
    )

    // MARK: - arguments

    @Argument(help: "The root directory (default: docs).")
    var root: String = "./docs"

    @Option(name: .shortAndLong)
    var hostname: String = "127.0.0.1"

    @Option(name: .shortAndLong)
    var port: Int = 3000

    @Option(name: .shortAndLong, help: "The log level to use.")
    var logLevel: Logger.Level = .info

    @Flag(name: .shortAndLong, help: "Version information.")
    var version: Bool = false

    // MARK: - run

    func run() async throws {
        guard !version else {
            print(GitVersion())
            return
        }
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
