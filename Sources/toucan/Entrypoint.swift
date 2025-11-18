//
//  Entrypoint.swift
//  Toucan
//
//  Created by Binary Birds on 2025. 04. 15..

import ArgumentParser
import Dispatch
import Foundation
import ToucanCore
import SystemPackage
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
        version: GeneratorInfo.current.version,
        helpNames: []  // disables auto -h/--help
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
            fatalError("argument error")
        }

        if subcommand.isEmpty || subcommand == "--help" || subcommand == "-h" {
            printHelp()
            return
        }

        let base = URL(fileURLWithPath: path).lastPathComponent
        let toucanCmd = base + "-" + subcommand

        let executableDir = URL(fileURLWithPath: path)
            .deletingLastPathComponent()
        let siblingBinary = executableDir.appendingPathComponent(toucanCmd).path

        let exe =
            FileManager.default.isExecutableFile(atPath: siblingBinary)
            ? Command(executablePath: FilePath(siblingBinary))
            : Command.findInPath(withName: toucanCmd)

        guard let resolvedExe = exe else {
            fputs("error: Unknown subcommand '\(subcommand)'\n\n", stderr)
            printHelp()
            return
        }

        let cmd =
            resolvedExe
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

    private func printHelp() {
        print(
            """
            OVERVIEW: Toucan Command

            A markdown-based Static Site Generator (SSG) written in Swift.

            USAGE:
            toucan <subcommand> ...
            or
            toucan-<subcommand> ...

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
