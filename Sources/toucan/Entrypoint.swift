//
//  Entrypoint.swift
//  Toucan
//
//  Created by Binary Birds on 2025. 04. 15..

import ArgumentParser
import Dispatch
import Foundation
import SwiftCommand
import ToucanCore

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
        version: GeneratorInfo.current.version,
        helpNames: []
    )

    @Argument(parsing: .allUnrecognized)
    var subcommand: [String]

    func run() async throws {
        var args = CommandLine.arguments

        guard
            args.count > 1,
            let path = args.popFirst(),
            let subcommand = args.popFirst()
        else {
            fatalError(
                "Missing arguments, at least one subcommand is required."
            )
        }

        let base = URL(fileURLWithPath: path).lastPathComponent
        let toucanCmd = base + "-" + subcommand

        if subcommand.isEmpty || subcommand == "--help" || subcommand == "-h" {
            displayHelp()
            return
        }
        if subcommand == "--version" {
            displayVersion()
            return
        }

        guard let exe = Command.findInPath(withName: toucanCmd) else {
            fatalError("Subcommand not found: `\(toucanCmd)`.")
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

    private func displayVersion() {
        print(Self.configuration.version)
    }

    private func displayHelp() {
        print(
            """
            OVERVIEW: \(Self.configuration.abstract)

            \(Self.configuration.discussion)

            USAGE:
            toucan <subcommand>

            SUBCOMMANDS:
            init            Initializes a new Toucan project
            generate        Build static files using configured targets
            watch           Watch for changes and auto-regenerate output
            serve           Start a local web server to preview the site

            OPTIONS:
            --version       Show the version.
            -h, --help      Show help information.
            """
        )
    }

}
