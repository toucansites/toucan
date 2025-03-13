import ArgumentParser
import Logging
import FileMonitor
import Foundation
import SwiftCommand

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
        version: "1.0.0-beta.3"
    )

    // MARK: - arguments

    @Argument(help: "The input directory (default: src).")
    var input: String = "./src"

    @Argument(help: "The output directory (default: docs).")
    var output: String = "./docs"

    @Option(name: .shortAndLong, help: "The base url to use.")
    var baseUrl: String? = nil

    @Option(name: .shortAndLong, help: "The log level to use.")
    var logLevel: Logger.Level = .debug

    func run() async throws {
        var logger = Logger(label: "toucan")
        logger.logLevel = logLevel

        let bin = "/usr/local/bin"

        /// test -x /usr/local/bin/toucan && /usr/local/bin/toucan --version || echo ""
        let versionCheck = try await Command
            .findInPath(withName: "sh")?
            .addArgument("-c")
            .addArgument(
                "test -x \(bin)/toucan && \(bin)/toucan --version || echo \"\""
            )
            .output
            .stdout

        guard let versionCheck = versionCheck, !versionCheck.isEmpty else {
            logger.error("Toucan is not installed.")
            return
        }

        logger.info("👀 Watching: `\(input)` -> \(output).")

        var options: [String: String] = [
            "--log-level": "\(logLevel)"
        ]
        if let baseUrl, !baseUrl.isEmpty {
            options["--base-url"] = baseUrl
        }
        let opt =
            options
            .map { "\($0.key) \($0.value)" }
            .joined(separator: " ")

        let home = FileManager.default.homeDirectoryForCurrentUser.path

        func getSafeUrl(_ path: String, home: String) -> URL {
            .init(
                fileURLWithPath: path.replacingOccurrences(of: "~", with: home)
            )
            .standardized
        }

        let inputUrl = getSafeUrl(input, home: home)
        let outputUrl = getSafeUrl(output, home: home)

        let generateCommand = [
            "\(bin)/toucan",
            "generate",
            inputUrl.path,
            outputUrl.path,
            opt,
        ]
        .joined(separator: " ")

        var lastGenerationTime = Date()

        let generate = try await Command
            .findInPath(withName: "sh")?
            .addArgument("-c")
            .addArgument(
                "\(bin)/toucan generate \(opt) \(inputUrl.path) \(outputUrl.path)"
            )
            .output
            .stdout

        if let generate, !generate.isEmpty {
            logger.debug(.init(stringLiteral: generate))
            return
        }

        let monitor = try FileMonitor(directory: inputUrl)
        try monitor.start()
        for await _ in monitor.stream {
            let now = Date()
            let last = lastGenerationTime
            let diff = abs(last.timeIntervalSince(now))

            guard diff > 3 else {  // 3 sec treshold
                logger.trace("Skipping generation due to treshold...")
                continue
            }
            lastGenerationTime = now
            logger.info("Generating site...")

            let generate = try await Command
                .findInPath(withName: "sh")?
                .addArgument("-c")
                .addArgument(
                    "\(bin)/toucan generate \(opt) \(inputUrl.path) \(outputUrl.path)"
                )
                .output
                .stdout

            if let generate, !generate.isEmpty {
                logger.debug(.init(stringLiteral: generate))
                return
            }
        }
    }
}
