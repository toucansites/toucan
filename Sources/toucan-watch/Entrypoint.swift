//
//  Entrypoint.swift
//  Toucan
//
//  Created by Binary Birds on 2025. 04. 15..

import ArgumentParser
import FileMonitor
import Foundation
import Logging
import SwiftCommand
import ToucanCore

extension Logger.Level: @retroactive ExpressibleByArgument {}

/// The main entry point for the command-line tool.
@main
struct Entrypoint: AsyncParsableCommand {
    // MARK: - Static Properties

    /// Configuration for the command-line tool.
    static let configuration = CommandConfiguration(
        commandName: "toucan-watch",
        abstract: """
        Toucan Watch Command
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

    @Option(
        name: .shortAndLong,
        help: "The treshold to watch for changes in seconds."
    )
    var seconds: Int = 3

    @Option(name: .shortAndLong, help: "The log level to use.")
    var logLevel: Logger.Level = .info

    // MARK: - Computed Properties

    var arguments: [String] {
        [input] + options
    }

    var options: [String] {
        var options: [String] = [
            "--log-level", "\(logLevel)",
        ]
        if let target, !target.isEmpty {
            options.append("--target")
            options.append(target)
        }
        return options
    }

    // MARK: - Functions

    func run() async throws {
        var logger = Logger(label: "toucan")
        logger.logLevel = logLevel

        let toucan = "/usr/local/bin/toucan"

        /// test -x /usr/local/bin/toucan && /usr/local/bin/toucan --version || echo ""
        //        let versionCheck = try await Command.findInPath(withName: "sh")?
        //            .addArgument("-c")
        //            .addArgument(
        //                "test -x \(toucan) && \(toucan) --version || echo \"\""
        //            )
        //            .output
        //            .stdout

        guard FileManager.default.isExecutableFile(atPath: toucan) else {
            logger.error("Toucan is not installed.")
            return
        }

        logger.info("👀 Watching: `\(input)`.")

        let inputURL = safeURL(for: input)

        var lastGenerationTime = Date()

        let commandURL = URL(fileURLWithPath: toucan)
        let command = Command(
            executablePath: .init(commandURL.path() + "-generate")
        )
        .addArguments(arguments)

        let generate = try await command.output.stdout

        if !generate.isEmpty {
            logger.debug(.init(stringLiteral: generate))
            return
        }

        let monitor = try FileMonitor(directory: inputURL)
        try monitor.start()
        for await _ in monitor.stream {
            let now = Date()
            let last = lastGenerationTime
            let diff = abs(last.timeIntervalSince(now))

            guard diff > Double(seconds) else { // 3 sec treshold
                logger.trace("Skipping generation due to treshold...")
                continue
            }
            lastGenerationTime = now
            logger.info("Generating site...")

            let generate = try await command.output.stdout

            if !generate.isEmpty {
                logger.debug(.init(stringLiteral: generate))
                return
            }
        }
    }

    func safeURL(for path: String) -> URL {
        let home = FileManager.default.homeDirectoryForCurrentUser.path
        let replaced = path.replacingOccurrences(of: "~", with: home)
        return .init(fileURLWithPath: replaced).standardized
    }
}
