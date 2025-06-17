//
//  Entrypoint.swift
//  Toucan
//
//  Created by Binary Birds on 2025. 04. 15..

import ArgumentParser
import Logging
import ToucanCore
import ToucanSDK

extension Logger.Level: @retroactive ExpressibleByArgument {}

/// The main entry point for the command-line tool.
@main
struct Entrypoint: AsyncParsableCommand {
    // MARK: - Static Properties

    /// Configuration for the command-line tool.
    static let configuration = CommandConfiguration(
        commandName: "toucan-generate",
        abstract: """
        Toucan Generate Command
        """,
        discussion: """
        A markdown-based Static Site Generator (SSG) written in Swift.
        """,
        version: GeneratorInfo.current.version
    )

    // MARK: - Properties

    // MARK: - arguments

    @Argument(help: "The input directory (default: src).")
    var input: String = "./src"

    @Option(
        name: .shortAndLong,
        help: "The target to build, if empty build all."
    )
    var target: String?

    @Option(name: .shortAndLong, help: "The log level to use.")
    var logLevel: Logger.Level = .info

    // MARK: - Functions

    // MARK: - run

    func run() async throws {
        var logger = Logger(label: "toucan")
        logger.logLevel = logLevel

        var targetsToBuild: [String] = []
        if let target, !target.isEmpty {
            targetsToBuild.append(target)
        }

        let generator = Toucan(
            input: input,
            targetsToBuild: targetsToBuild,
            logger: logger
        )

        if generator.generateAndLogErrors(logger) {
            let metadata: Logger.Metadata = [
                "input": "\(input)",
            ]
            logger.info("Site generated successfully.", metadata: metadata)
        }
    }
}
