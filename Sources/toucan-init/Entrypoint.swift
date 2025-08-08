//
//  Entrypoint.swift
//  Toucan
//
//  Created by Binary Birds on 2025. 04. 15..

import ArgumentParser
import FileManagerKit
import Foundation
import Logging
import ToucanCore
import ToucanSource

extension Logger.Level: @retroactive ExpressibleByArgument {}

/// The main entry point for the command-line tool.
@main
struct Entrypoint: AsyncParsableCommand {
    /// Configuration for the command-line tool.
    static let configuration = CommandConfiguration(
        commandName: "toucan-init",
        abstract: """
            Toucan Init Command
            """,
        discussion: """
            A markdown-based Static Site Generator (SSG) written in Swift.
            """,
        version: GeneratorInfo.current.release
    )

    @Argument(help: "The name of the site directory (default: site).")
    var siteDirectory: String = "site"

    @Option(name: .shortAndLong, help: "The log level to use.")
    var logLevel: Logger.Level = .info

    @Option(
        name: .shortAndLong,
        help:
            "Specifies a URL to a remote zip file containing a demo project to use as the starting point. If not specified, a minimal setup will be used."
    )
    var demoSourceZipURL: String?

    func run() async throws {
        var logger = Logger.subsystem("main")
        logger.logLevel = logLevel

        let siteExists = fileManager.directoryExists(at: siteDirectoryURL)

        guard !siteExists else {
            logger.error("Folder already exists: \(siteDirectoryURL)")
            return
        }

        do {
            let sourceUrl = demoSourceZipURL.flatMap { URL(string: $0) }

            let source = Download(
                sourceURL: sourceUrl ?? minimalSourceURL,
                targetDirURL: siteDirectoryURL,
                fileManager: fileManager
            )

            logger.trace("Preparing files.")
            try await source.resolve()

            logger.trace("'\(siteDirectory)' was prepared successfully.")
        }
        catch {
            logger.error("\(String(describing: error))")
        }
    }
}

extension Entrypoint {
    var fileManager: FileManager { .default }

    var currentDirectoryURL: URL {
        URL(fileURLWithPath: fileManager.currentDirectoryPath)
    }

    var siteDirectoryURL: URL {
        currentDirectoryURL.appendingPathComponent(siteDirectory)
    }

    var minimalSourceURL: URL {
        .init(
            string:
                "https://github.com/toucansites/minimal-template-demo/archive/refs/heads/main.zip"
        )!
    }
}
