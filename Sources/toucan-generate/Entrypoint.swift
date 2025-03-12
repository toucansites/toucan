import ArgumentParser
import ToucanSDK
import Logging

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
    var logLevel: Logger.Level = .info

    // MARK: - run

    func run() async throws {
        var logger = Logger(label: "toucan")
        logger.logLevel = logLevel

        let generator = Toucan(
            input: input,
            output: output,
            baseUrl: baseUrl,
            logger: logger
        )

        if generator.generateAndLogErrors(logger) {
            let metadata: Logger.Metadata = [
                "input": "\(input)",
                "output": "\(output)",
                "baseUrl": "\(String(describing: baseUrl?.description))",
            ]
            logger.info("Site generated successfully.", metadata: metadata)
        }
    }
}
