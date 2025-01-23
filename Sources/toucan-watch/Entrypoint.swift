import ArgumentParser
import ToucanSDK
import Logging
import ShellKit
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
        let shell = Shell()

        let dir = FileManager.default.homeDirectoryForCurrentUser.appending(path: "Downloads")
        let monitor = try FileMonitor(directory: dir)
        try monitor.start()
        for await _ in monitor.stream {
            let output = try shell.run(
                #"/usr/local/bin/toucan --version"#
            )
            print(output)
//            switch event {
//            case .added(let file):
//                print("New file \(file.path)")
//            default:
//                print("\(event)")
//            }
        }   
    }
}

/*
 watchman -- trigger ./src toucan-trigger '*' -- /usr/local/bin/toucan generate --base-url http://localhost:3000/
 watchman trigger-list ./src
 watchman trigger-del ./src toucan-trigger
 */
