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
    /// Configuration for the command-line tool.
    static let configuration = CommandConfiguration(
        commandName: "toucan-watch",
        abstract: """
            Toucan Watch Command
            """,
        discussion: """
            A markdown-based Static Site Generator (SSG) written in Swift.
            """,
        version: GeneratorInfo.current.release.description
    )

    @Argument(help: "The input directory (default: current working directory).")
    var input: String = "."

    @Option(
        name: .shortAndLong,
        help:
            "The directory to ignore, relative to the working directory (default: dist)."
    )
    var ignore: String = "dist"

    @Option(
        name: .shortAndLong,
        help: "The target to build, if empty build all."
    )
    var target: String?

    @Option(
        name: .shortAndLong,
        help: "The treshold to watch for changes in seconds (default: 3)."
    )
    var seconds: Int = 3

    var arguments: [String] {
        [input] + options
    }

    var options: [String] {
        var options: [String] = []
        if let target, !target.isEmpty {
            options.append("--target")
            options.append(target)
        }
        return options
    }

    func run() async throws {
        let logger = Logger.subsystem("watch")

        let metadata: Logger.Metadata = [
            "input": .string(input),
            "target": .string(target ?? "(default)"),
            "ignore": .string(ignore),
            "treshold": .string(String(seconds)),
        ]

        logger.info(
            "👀 Watching Toucan site.",
            metadata: metadata
        )

        //
        // NOTE: To test this feature
        //
        // 1. Make sure Toucan is installed somwehere.
        // 2. Edit scheme in Xcode or use `setenv`, e.g.:
        //     `setenv("PATH", "/usr/local/bin", 1)`
        // 3. Set a `PATH` environment variable:
        //      `PATH=/usr/local/bin`
        //
        let currentToucanCommand = Command.findInPath(withName: "toucan")
        let toucanCommandUrl = currentToucanCommand?.executablePath.string

        guard let toucan = toucanCommandUrl,
            FileManager.default.isExecutableFile(atPath: toucan)
        else {
            logger.error(
                "Toucan is not installed.",
                metadata: metadata
            )
            return
        }

        let inputURL = safeURL(for: input)

        let commandURL = URL(fileURLWithPath: toucan)
        let command = Command(
            executablePath: .init(commandURL.path() + "-generate")
        )
        .addArguments(arguments)

        let generate = try await command.output.stdout

        if !generate.isEmpty {
            logger.debug(
                .init(stringLiteral: generate),
                metadata: metadata
            )
            return
        }

        let ignoreURL = inputURL.appendingPathIfPresent(ignore)

        let monitor = try FileMonitor(directory: inputURL)
        try monitor.start()
        for await event in monitor.stream.debounce(for: .seconds(seconds)) {

            let eventPath = event.url.path()
            guard !eventPath.hasPrefix(ignoreURL.path()) else {
                logger.trace(
                    "Skipping generation due to ignore path.",
                    metadata: metadata
                )
                continue
            }

            logger.info(
                "Generating site.",
                metadata: metadata
            )

            let generate = try await command.output.stdout

            if !generate.isEmpty {
                logger.debug(
                    .init(stringLiteral: generate),
                    metadata: metadata
                )
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
