//
//  File.swift
//
//
//  Created by Tibor Bodecs on 03/05/2024.
//

import Foundation
import FileManagerKit
import Logging
import ToucanFileSystem
import ToucanTesting

public struct Toucan {

    let inputUrl: URL
    let outputUrl: URL
    let baseUrl: String?
    let logger: Logger

    let fileManager: FileManagerKit
    let yamlParser: YamlParser
    let frontMatterParser: FrontMatterParser

    let fs: ToucanFileSystem

    /// Initialize a new instance.
    /// - Parameters:
    ///   - input: The input url as a path string.
    ///   - output: The output url as a path string.
    ///   - baseUrl: An optional baseUrl to override the config value.
    public init(
        input: String,
        output: String,
        baseUrl: String?,
        logger: Logger = .init(label: "toucan")
    ) {
        self.fileManager = FileManager.default
        self.yamlParser = YamlParser()
        self.frontMatterParser = FrontMatterParser(yamlParser: yamlParser)

        let home = fileManager.homeDirectoryForCurrentUser.path

        func getSafeUrl(_ path: String, home: String) -> URL {
            .init(
                fileURLWithPath: path.replacingOccurrences(["~": home])
            )
            .standardized
        }

        self.inputUrl = getSafeUrl(input, home: home)
        self.outputUrl = getSafeUrl(output, home: home)
        self.baseUrl = baseUrl
        self.logger = logger
        self.fs = .init(fileManager: fileManager)
    }

    // MARK: - directory management

    func resetDirectory(at url: URL) throws {
        if fileManager.exists(at: url) {
            try fileManager.delete(at: url)
        }
        try fileManager.createDirectory(at: url)
    }

    /// generates the static site
    public func generate() throws {
        let processId = UUID()
        let workDirUrl = fileManager
            .temporaryDirectory
            .appendingPathComponent("toucan")
            .appendingPathComponent(processId.uuidString)

        try resetDirectory(at: workDirUrl)

        logger.debug("Working at: `\(workDirUrl.absoluteString)`.")

        do {
            let sourceLoader = SourceLoader(
                sourceUrl: inputUrl,
                fileManager: fileManager,
                yamlParser: yamlParser,
                frontMatterParser: frontMatterParser,
                logger: logger
            )
            let sourceBundle = try sourceLoader.load()
            
            // TODO: - do we need this?
            // source.validate(dateFormatter: DateFormatters.baseFormatter)
            
            let results = try sourceBundle.generatePipelineResults()

            // MARK: - Preparing work dir
            
            try resetDirectory(at: workDirUrl)

            // MARK: - Copy assets
            
            print("TODO: - add assets copy here")
            
            // MARK: - Writing results
            
            for result in results {
                let folder = workDirUrl.appending(path: result.destination.path)
                try FileManager.default.createDirectory(at: folder)

                let outputUrl =
                    folder
                    .appending(path: result.destination.file)
                    .appendingPathExtension(result.destination.ext)

                try result.contents.write(
                    to: outputUrl,
                    atomically: true,
                    encoding: .utf8
                )
            }
            
            // MARK: - Finalize and cleanup
            
            try resetDirectory(at: outputUrl)
            // TODO: - copy recursively
            // try fileManager.copyRecursively(from: workDirUrl, to: outputUrl)
            try? fileManager.delete(at: workDirUrl)
        }
        catch {
            try? fileManager.delete(at: workDirUrl)
            throw error
        }
    }
}
