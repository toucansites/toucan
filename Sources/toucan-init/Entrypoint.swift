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

extension Logger.Level: @retroactive ExpressibleByArgument {}

/// The main entry point for the command-line tool.
@main
struct Entrypoint: AsyncParsableCommand {
    // MARK: - Static Properties

    /// Configuration for the command-line tool.
    static let configuration = CommandConfiguration(
        commandName: "toucan-init",
        abstract: """
            Toucan Init Command
            """,
        discussion: """
            A markdown-based Static Site Generator (SSG) written in Swift.
            """,
        version: GeneratorInfo.current.version
    )

    // MARK: - Properties

    // MARK: - arguments

    @Argument(help: "The name of the site directory (default: site).")
    var siteDirectory: String = "site"

    @Option(name: .shortAndLong, help: "The log level to use.")
    var logLevel: Logger.Level = .info

    // MARK: - Functions

    // MARK: - run

    func run() async throws {
        var logger = Logger(label: "toucan")
        logger.logLevel = logLevel

        let siteExists = fileManager.directoryExists(at: siteDirectoryURL)

        guard !siteExists else {
            logger.error("Folder already exists: \(siteDirectoryURL)")
            return
        }

        do {
            let source = Download(
                sourceURL: minimalSourceURL,
                targetDirURL: siteDirectoryURL,
                fileManager: fileManager
            )
            let template = Download(
                sourceURL: minimalTemplateURL,
                targetDirURL: defaultTemplatesURL,
                fileManager: fileManager
            )

            logger.info("Preparing source files.")
            try await source.resolve()

            logger.info("Preparing template files.")
            try await template.resolve()

            logger.info("'\(siteDirectory)' was prepared successfully.")
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
                "https://github.com/toucansites/minimal-example/archive/refs/heads/main.zip"
        )!
    }

    var minimalTemplateURL: URL {
        .init(
            string:
                "https://github.com/toucansites/minimal-theme/archive/refs/heads/main.zip"
        )!
    }

    var defaultTemplatesURL: URL {
        siteDirectoryURL.appendingPathComponent("src/templates/default")
    }
}
