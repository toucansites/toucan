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

        logger.info("👀 Watching: `\(input)` -> \(output).")

        var options: [String] = [
            "--log-level", "\(logLevel)",
        ]
        if let baseUrl, !baseUrl.isEmpty {
            options.append("--base-url")
            options.append(baseUrl)
        }

        let inputUrl = safeUrl(for: input)
        let outputUrl = safeUrl(for: output)

        var lastGenerationTime = Date()

        let commandUrl = URL(fileURLWithPath: toucan)
        let command = Command(
            executablePath: .init(commandUrl.path() + "-generate")
        )
        .addArguments(
            [
                inputUrl.path(),
                outputUrl.path(),
            ] + options
        )

        let generate = try await command.output.stdout

        if !generate.isEmpty {
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

            let command = Command(
                executablePath: .init(commandUrl.path() + "-generate")
            )
            .addArguments(
                [
                    inputUrl.path(),
                    outputUrl.path(),
                ] + options
            )

            let generate = try await command.output.stdout

            if !generate.isEmpty {
                logger.debug(.init(stringLiteral: generate))
                return
            }
        }
    }

    var options: [String] {
        var options: [String] = [
            "--log-level", "\(logLevel)",
        ]
        if let baseUrl, !baseUrl.isEmpty {
            options.append("--base-url")
            options.append(baseUrl)
        }
        return options
    }

    func safeUrl(for path: String) -> URL {
        let home = FileManager.default.homeDirectoryForCurrentUser.path
        let replaced = path.replacingOccurrences(of: "~", with: home)
        return .init(fileURLWithPath: replaced).standardized
    }
}
