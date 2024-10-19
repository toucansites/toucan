import Foundation
import ArgumentParser
import ToucanSDK
import Logging
import FileManagerKit
import ZIPFoundation
import AsyncHTTPClient
import NIOFoundationCompat

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

                try await source.resolve()
                try await theme.resolve()

                logger.info("'\(siteDirectory)' was created successfully.")
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
        currentDirUrl.appending(path: siteDirectory)
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
        siteDirUrl.appending(path: "src/themes/default")
    }
}

extension Entrypoint.Init {

    struct Download {

        let id = UUID().uuidString
        let sourceUrl: URL
        let targetDirUrl: URL
        let fileManager: FileManager

        private var url: URL {
            fileManager.temporaryDirectory.appending(path: id)
        }

        private var zipUrl: URL {
            url.appendingPathExtension("zip")
        }

        func resolve() async throws {
            /// Downloading the ZIP file into a temporary directory.
            let client = HTTPClient(eventLoopGroupProvider: .singleton)
            defer { _ = client.shutdown() }

            let request = try HTTPClient.Request(
                url: sourceUrl.absoluteString,
                method: .GET
            )
            let response = try await client.execute(request: request).get()

            guard
                var body = response.body,
                let data = body.readData(length: body.readableBytes)
            else {
                throw URLError(.badServerResponse)
            }

            try data.write(to: zipUrl)

            /// Unzipping the file to a temporary directory.
            try fileManager.unzipItem(at: zipUrl, to: url)

            /// Emptying the target directory. Git submodules can cause issues.
            try? fileManager.removeItem(at: targetDirUrl)

            /// Finding the root directory URL.
            let items = fileManager.listDirectory(at: url)
            guard let rootDirName = items.first else {
                throw URLError(.cannotParseResponse)
            }
            let rootDirUrl = url.appending(path: rootDirName)

            /// Moving files to the target directory.
            try fileManager.moveItem(at: rootDirUrl, to: targetDirUrl)

            /// Cleaning up unnecessary files.
            try? fileManager.delete(at: zipUrl)
            try? fileManager.delete(at: url)
        }
    }
}
