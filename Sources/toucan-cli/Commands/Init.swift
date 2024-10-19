import Foundation
import ArgumentParser
import ToucanSDK
import Logging
import FileManagerKit
import ShellKit

extension Entrypoint {

    struct Init: AsyncParsableCommand {

        @Argument(help: "The name of the site directory (default: site).")
        var siteDirectory: String = "site"

        @Option(name: .shortAndLong, help: "The log level to use.")
        var logLevel: Logger.Level = .info

        func run() async throws {
            var logger = Logger(label: "toucan")
            logger.logLevel = logLevel

            let siteExists = fileManager.directoryExists(at: siteDirUrl)

            guard !siteExists else {
                logger.error("Folder already exists: \(siteDirUrl)")
                return
            }

            do {
                let source = Download(
                    sourceUrl: exampleSourceUrl,
                    targetDirUrl: siteDirUrl,
                    fileManager: fileManager
                )
                let theme = Download(
                    sourceUrl: exampleThemeUrl,
                    targetDirUrl: themesDefaultDirUrl,
                    fileManager: fileManager
                )

                logger.info("Preparing source files.")
                try await source.resolve()

                logger.info("Preparing theme files.")
                try await theme.resolve()

                logger.info("'\(siteDirectory)' was prepared successfully.")
            }
            catch {
                logger.error("\(String(describing: error))")
            }
        }
    }
}

extension Entrypoint.Init {

    var fileManager: FileManager { .default }

    var currentDirUrl: URL {
        URL(fileURLWithPath: fileManager.currentDirectoryPath)
    }

    var siteDirUrl: URL {
        currentDirUrl.appendingPathComponent(siteDirectory)
    }

    var exampleSourceUrl: URL {
        .init(
            string:
                "https://github.com/toucansites/minimal-example/archive/refs/heads/main.zip"
        )!
    }

    var exampleThemeUrl: URL {
        .init(
            string:
                "https://github.com/toucansites/minimal-theme/archive/refs/heads/main.zip"
        )!
    }

    var themesDefaultDirUrl: URL {
        siteDirUrl.appendingPathComponent("src/themes/default")
    }
}

extension Entrypoint.Init {

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
            let shell = Shell()

            /// Downloading the ZIP file into a temporary directory.
            try shell.run(
                #"curl -L -o \#(zipUrl.path) \#(sourceUrl.absoluteString)"#
            )

            /// Unzipping the file to a temporary directory.
            try shell.run(#"unzip \#(zipUrl.path) -d \#(url.path)"#)

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
}
