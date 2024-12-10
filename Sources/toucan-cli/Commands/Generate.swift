import Foundation
import ArgumentParser
import ToucanSDK
import Logging

extension Entrypoint {

    struct Generate: AsyncParsableCommand {

        @Argument(help: "The input directory (default: src).")
        var input: String = "./src"

        @Argument(help: "The output directory (default: docs).")
        var output: String = "./docs"

        @Option(name: .shortAndLong, help: "The base url to use.")
        var baseUrl: String? = nil

        @Option(name: .shortAndLong, help: "The log level to use.")
        var logLevel: Logger.Level = .info

        @Flag(name: .shortAndLong, help: "SEO checks")
        var seoChecks = false

        func run() async throws {
            var logger = Logger(label: "toucan")
            logger.logLevel = logLevel

            let generator = Toucan(
                input: input,
                output: output,
                baseUrl: baseUrl,
                seoChecks: seoChecks,
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
}
