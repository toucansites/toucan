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

    /// Configuration for the command-line tool.
    static let configuration = CommandConfiguration(
        commandName: "toucan-generate",
        abstract: """
            Toucan Generate Command
            """,
        discussion: """
            A markdown-based Static Site Generator (SSG) written in Swift.
            """,
        version: GeneratorInfo.current.release
    )

    @Argument(
        help: """
                The working directory to look for a `toucan.yml` file.  
                
                Default: current working directory
            """
    )
    var workDir: String = "."

    @Option(
        name: .shortAndLong,
        help: "The target to build, if empty build all."
    )
    var target: String?

    @Option(name: .shortAndLong, help: "The log level to use.")
    var logLevel: Logger.Level = .info

    func run() async throws {
        var logger = Logger.subsystem("main")
        logger.logLevel = logLevel

        var targetsToBuild: [String] = []
        if let target, !target.isEmpty {
            targetsToBuild.append(target)
        }

        let generator = Toucan()

        if generator.generateAndLogErrors(
            workDir: workDir,
            targetsToBuild: targetsToBuild,
            now: .init()
        ) {
            let metadata: Logger.Metadata = [
                "workDir": .string(workDir)
            ]
            logger.info("Site generated successfully.", metadata: metadata)
        }
    }
}
