//
//  Entrypoint.swift
//  Toucan
//
//  Created by Binary Birds on 2025. 04. 15..

import ArgumentParser
import Foundation
import Hummingbird
import Logging
import ToucanCore

extension Logger.Level: @retroactive ExpressibleByArgument {}

/// The main entry point for the command-line tool.
@main
struct Entrypoint: AsyncParsableCommand {
    /// Configuration for the command-line tool.
    static let configuration = CommandConfiguration(
        commandName: "toucan-serve",
        abstract: """
            Toucan Serve Command
            """,
        discussion: """
            Serves a directory over a local web-server.
            """,
        version: GeneratorInfo.current.version
    )

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
