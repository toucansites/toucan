import Foundation
import ArgumentParser
import Logging
import FileManagerKit

extension Logger.Level: @retroactive ExpressibleByArgument {}

/// The main entry point for the command-line tool.
@main
struct Entrypoint: AsyncParsableCommand {

    /// Configuration for the command-line tool.
    static let configuration = CommandConfiguration(
        commandName: "toucan-init",
        abstract: """
            Toucan
            """,
        discussion: """
            A markdown-based Static Site Generator (SSG) written in Swift.
            """,
        version: "1.0.0-beta.2"
    )

    // MARK: - arguments

    @Argument(help: "The name of the site directory (default: site).")
    var siteDirectory: String = "site"

    @Option(name: .shortAndLong, help: "The log level to use.")
    var logLevel: Logger.Level = .info

    // MARK: - run

    func run() async throws {
        var logger = Logger(label: "toucan")
        logger.logLevel = logLevel

        let siteExists = fileManager.directoryExists(at: siteDirUrl)

        guard !siteExists else {
            logger.error("Folder already exists: \(siteDirUrl)")
            return
        }

        do {
            let source = Download(
                sourceUrl: exampleSourceUrl,
                targetDirUrl: siteDirUrl,
                fileManager: fileManager
            )
            let theme = Download(
                sourceUrl: exampleThemeUrl,
                targetDirUrl: themesDefaultDirUrl,
                fileManager: fileManager
            )

            logger.info("Preparing source files.")
            try await source.resolve()

            logger.info("Preparing theme files.")
            try await theme.resolve()

            logger.info("'\(siteDirectory)' was prepared successfully.")
        }
        catch {
            logger.error("\(String(describing: error))")
        }
    }
}

extension Entrypoint {

    var fileManager: FileManager { .default }

    var currentDirUrl: URL {
        URL(fileURLWithPath: fileManager.currentDirectoryPath)
    }

    var siteDirUrl: URL {
        currentDirUrl.appendingPathComponent(siteDirectory)
    }

    var exampleSourceUrl: URL {
        .init(
            string:
                "https://github.com/toucansites/minimal-example/archive/refs/heads/main.zip"
        )!
    }

    var exampleThemeUrl: URL {
        .init(
            string:
                "https://github.com/toucansites/minimal-theme/archive/refs/heads/main.zip"
        )!
    }

    var themesDefaultDirUrl: URL {
        siteDirUrl.appendingPathComponent("src/themes/default")
    }
}
