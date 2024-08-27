import ArgumentParser
import ToucanSDK

/// The main entry point for the command-line tool.
@main
struct Entrypoint: ParsableCommand {

    /// Configuration for the command-line tool.
    static var configuration = CommandConfiguration(
        commandName: "toucan",
        abstract: """
            Toucan
            """,
        discussion: """
            A markdown-based Static Site Generator (SSG) written in Swift.
            """,
        version: "0.1.0",
        subcommands: [
            Generate.self,
            Serve.self,
            Watch.self,
        ]
    )
}
