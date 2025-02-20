import Foundation
import FileManagerKit
//import ShellKit

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
//        let shell = Shell()

        /// Downloading the ZIP file into a temporary directory.
//        try shell.run(
//            #"curl -L -o \#(zipUrl.path) \#(sourceUrl.absoluteString)"#
//        )

        /// Unzipping the file to a temporary directory.
//        try shell.run(#"unzip \#(zipUrl.path) -d \#(url.path)"#)

        /// Emptying the target directory. Git submodules can cause issues.
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
