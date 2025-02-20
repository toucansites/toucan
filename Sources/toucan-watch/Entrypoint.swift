import ArgumentParser
import Logging
import FileMonitor
import Foundation

extension Logger.Level: @retroactive ExpressibleByArgument {}

/// The main entry point for the command-line tool.
@main
struct Entrypoint: AsyncParsableCommand {

    /// Configuration for the command-line tool.
    static let configuration = CommandConfiguration(
        commandName: "toucan-watch",
        abstract: """
            Toucan
            """,
        discussion: """
            A markdown-based Static Site Generator (SSG) written in Swift.
            """,
        version: "1.0.0-beta.2"
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

    func run() async throws {
        var logger = Logger(label: "toucan")
        logger.logLevel = logLevel

        let bin = "/usr/local/bin"
        //        let shell = Shell()

        //        let versionCheckOutput = try shell.run(
        //            #"test -x \#(bin)/toucan && echo \#(bin)/toucan --version || echo """#
        //        )
        //        guard !versionCheckOutput.isEmpty else {
        //            logger.error("Toucan is not installed.")
        //            return
        //        }

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

        let cmd = [
            "\(bin)/toucan",
            "generate",
            inputUrl.path,
            outputUrl.path,
            opt,
        ]
        .joined(separator: " ")

        var lastGenerationTime = Date()
        //        let output = try shell.run(cmd)
        //        if !output.isEmpty {
        //            logger.debug("\(output)")
        //        }

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
            //            let output = try shell.run(cmd)
            //            if !output.isEmpty {
            //                logger.debug("\(output)")
            //            }
            //            switch event {
            //            case .added(let file):
            //                print("New file \(file.path)")
            //            default:
            //                print("\(event)")
            //            }
        }
    }
}
