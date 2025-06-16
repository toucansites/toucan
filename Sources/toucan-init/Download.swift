//
//  Download.swift
//  Toucan
//
//  Created by Binary Birds on 2025. 03. 31..

import FileManagerKit
import Foundation
import SwiftCommand

struct Download {
    // MARK: - Properties

    let id = UUID().uuidString
    let sourceURL: URL
    let targetDirURL: URL
    let fileManager: FileManager

    // MARK: - Computed Properties

    private var url: URL {
        fileManager.temporaryDirectory.appendingPathComponent(id)
    }

    private var zipURL: URL {
        url.appendingPathExtension("zip")
    }

    // MARK: - Functions

    func resolve() async throws {
        /// Ensure working directory exists
        try fileManager.createDirectory(
            at: url,
            withIntermediateDirectories: true
        )
        let zipURL = url.appendingPathExtension("zip")

        /// Find and run `curl` using SwiftCommand
        guard let curl = Command.findInPath(withName: "curl") else {
            fatalError("Command not found: 'curl'")
        }
        _ =
            try await curl
                .addArguments([
                    "-L",
                    sourceURL.absoluteString,
                    "-o",
                    zipURL.path,
                ])
                .output

        /// Find and run `unzip` using SwiftCommand
        guard let unzipExe = Command.findInPath(withName: "unzip") else {
            fatalError("Command not found 'unzip'")
        }
        _ =
            try await unzipExe
                .addArguments([zipURL.path, "-d", url.path])
                .output

        /// Remove existing target directory
        try? fileManager.removeItem(at: targetDirURL)

        /// Finding the root directory URL.
        let items = fileManager.listDirectory(at: url)
        guard let rootDirName = items.first else {
            throw URLError(.cannotParseResponse)
        }
        let rootDirURL = url.appendingPathComponent(rootDirName)

        /// Moving files to the target directory.
        try fileManager.moveItem(at: rootDirURL, to: targetDirURL)

        /// Cleaning up unnecessary files.
        try? fileManager.delete(at: zipURL)
        try? fileManager.delete(at: url)
    }
}
