import Foundation
import FileManagerKit
import SwiftCommand

struct Download {

    let id = UUID().uuidString
    let sourceUrl: URL
    let targetDirUrl: URL
    let fileManager: FileManager

    private var url: URL {
        fileManager.temporaryDirectory.appendingPathComponent(id)
    }

    private var zipUrl: URL {
        url.appendingPathExtension("zip")
    }

    func resolve() async throws {

        /// Ensure working directory exists
        try fileManager.createDirectory(
            at: url,
            withIntermediateDirectories: true
        )
        let zipUrl = url.appendingPathExtension("zip")

        /// Find and run `curl` using SwiftCommand
        guard let curl = Command.findInPath(withName: "curl") else {
            fatalError("Command not found: 'curl'")
        }
        _ =
            try await curl
            .addArguments(["-L", sourceUrl.absoluteString, "-o", zipUrl.path])
            .output

        /// Find and run `unzip` using SwiftCommand
        guard let unzipExe = Command.findInPath(withName: "unzip") else {
            fatalError("Command not found 'unzip'")
        }
        _ =
            try await unzipExe
            .addArguments([zipUrl.path, "-d", url.path])
            .output

        /// Remove existing target directory
        try? fileManager.removeItem(at: targetDirUrl)

        /// Finding the root directory URL.
        let items = fileManager.listDirectory(at: url)
        guard let rootDirName = items.first else {
            throw URLError(.cannotParseResponse)
        }
        let rootDirUrl = url.appendingPathComponent(rootDirName)

        /// Moving files to the target directory.
        try fileManager.moveItem(at: rootDirUrl, to: targetDirUrl)

        /// Cleaning up unnecessary files.
        try? fileManager.delete(at: zipUrl)
        try? fileManager.delete(at: url)
    }
}
