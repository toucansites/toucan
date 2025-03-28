import Foundation
import Dispatch
import ArgumentParser
import SwiftCommand

extension Array {

    mutating func popFirst() -> Element? {
        isEmpty ? nil : removeFirst()
    }
}

/// The main entry point for the command-line tool.
@main
struct Entrypoint: AsyncParsableCommand {

    /// Configuration for the command-line tool.
    static let configuration = CommandConfiguration(
        commandName: "toucan",
        abstract: """
            Toucan
            """,
        discussion: """
            A markdown-based Static Site Generator (SSG) written in Swift.
            """,
        version: "1.0.0-beta.3"
    )

    // MARK: - arguments

    @Argument(parsing: .allUnrecognized)
    var subcommand: [String]

    func run() async throws {
        var args = CommandLine.arguments

        guard
            args.count > 1,
            let path = args.popFirst(),
            let subcommand = args.popFirst()
        else {
            fatalError("argument error")
        }

        let base = URL(fileURLWithPath: path).lastPathComponent
        let toucanCmd = base + "-" + subcommand

        guard let exe = Command.findInPath(withName: toucanCmd) else {
            fatalError("Command not found (\(toucanCmd)).")
        }
        let cmd =
            exe
            .addArguments(args)
            .setStdin(.pipe(closeImplicitly: false))
            .setStdout(.inherit)
            .setStderr(.inherit)

        let subprocess = try cmd.spawn()

        let signalSource = DispatchSource.makeSignalSource(
            signal: SIGINT,
            queue: .main
        )
        signal(SIGINT, SIG_IGN)  // Ignore default SIGINT behavior

        signalSource.setEventHandler {
            if subprocess.isRunning {
                subprocess.interrupt()
            }
        }
        signalSource.resume()

        try subprocess.wait()
    }
}
