//
//  Toucan.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 04. 17..
//

import Foundation
import FileManagerKit
import Logging
import ToucanSerialization
import ToucanSource

private func getSafeUrl(
    for path: String,
    using fileManager: FileManagerKit
) -> URL {
    let home = fileManager.homeDirectoryForCurrentUser.path
    return
        .init(
            fileURLWithPath: path.replacingOccurrences(["~": home])
        )
        .standardized
}

/// Primary entry point for generating a static site using the Toucan framework.
public struct Toucan {

    let inputUrl: URL
    let targetsToBuild: [String]
    let logger: Logger

    let fileManager: FileManagerKit
    //    let markdownParser: MarkdownParser
    let encoder: ToucanEncoder
    let decoder: ToucanDecoder

    /// Initialize a new instance.
    /// - Parameters:
    ///   - input: The input url as a path string.
    ///   - targetsToBuild: The list of target names to build.
    ///   - logger: A logger instance for logging. Defaults to a logger labeled "toucan".
    public init(
        input: String,
        targetsToBuild: [String],
        logger: Logger = .init(label: "toucan")
    ) {
        self.fileManager = FileManager.default
        self.encoder = ToucanYAMLEncoder()
        self.decoder = ToucanYAMLDecoder()
        self.inputUrl = getSafeUrl(for: input, using: fileManager)
        self.targetsToBuild = targetsToBuild
        self.logger = logger
    }

    // MARK: - helpers

    func resetDirectory(at url: URL) throws {
        if fileManager.exists(at: url) {
            try fileManager.delete(at: url)
        }
        try fileManager.createDirectory(at: url)
    }

    func prepareWorkingDirectory() throws -> URL {
        let url = fileManager
            .temporaryDirectory
            .appendingPathComponent("toucan")
            .appendingPathComponent(UUID().uuidString)

        try resetDirectory(at: url)

        logger.debug("Working at: `\(url.absoluteString)`.")

        return url
    }

    // MARK: -

    func loadTargetConfig() throws -> TargetConfig {
        try ObjectLoader(
            url: inputUrl,
            locations:
                fileManager
                .find(
                    name: "toucan",
                    extensions: ["yml", "yaml"],
                    at: inputUrl
                ),
            encoder: encoder,
            decoder: decoder,
            logger: logger
        )
        .load(TargetConfig.self)
    }

    func getActiveBuildTargets(
        _ targetConfig: TargetConfig
    ) -> [Target] {
        // TODO: maybe support --targets flag
        var buildTargets = targetConfig.targets.filter {
            targetsToBuild.contains($0.name)
        }
        if buildTargets.isEmpty {
            buildTargets.append(targetConfig.default)
        }
        return buildTargets
    }

    // MARK: - api

    /// generates the static site
    public func generate() throws {
        let workDirUrl = try prepareWorkingDirectory()

        do {
            let targetConfig = try loadTargetConfig()
            let activeBuildTargets = getActiveBuildTargets(targetConfig)

            for target in activeBuildTargets {
                logger.info(
                    "Building target: \(target.name)",
                    metadata: [:]
                )
                let buildTargetSourceLoader = BuildTargetSourceLoader(
                    sourceUrl: inputUrl,
                    target: target,
                    fileManager: fileManager,
                    encoder: encoder,
                    decoder: decoder,
                    logger: logger
                )

                let buildTargetSource = try buildTargetSourceLoader.load()

                let themeLoader = ThemeLoader(
                    locations: buildTargetSource.locations,
                    fileManager: fileManager
                )

                let theme = try themeLoader.load()
                let templates = themeLoader.getTemplatesIDsWithContents(theme)

                let validator = BuildTargetSourceValidator(
                    buildTargetSource: buildTargetSource
                )
                try validator.validate()

                var renderer = BuildTargetSourceRenderer(
                    buildTargetSource: buildTargetSource,
                    templates: templates,
                    fileManager: fileManager,
                    logger: logger
                )

                let results = try renderer.render(now: Date())

                try resetDirectory(at: workDirUrl)

                // MARK: - Copy default assets

                let copyManager = CopyManager(
                    fileManager: fileManager,
                    sources: [
                        buildTargetSource.locations.currentThemeAssetsUrl,
                        buildTargetSource.locations
                            .currentThemeAssetOverridesUrl,
                        buildTargetSource.locations.siteAssetsUrl,
                    ],
                    destination: workDirUrl
                )
                try copyManager.copy()

                // MARK: - Writing results

                for result in results {
                    let destinationFolder = workDirUrl.appending(
                        path: result.destination.path
                    )
                    try fileManager.createDirectory(at: destinationFolder)

                    let resultOutputUrl =
                        destinationFolder
                        .appending(path: result.destination.file)
                        .appendingPathExtension(result.destination.ext)

                    switch result.source {
                    case .assetFile(let path):
                        let srcUrl = buildTargetSource.locations.contentsUrl
                            .appending(path: path)
                        try fileManager.copy(from: srcUrl, to: resultOutputUrl)
                    case .asset(let string), .content(let string):
                        try string.write(
                            to: resultOutputUrl,
                            atomically: true,
                            encoding: .utf8
                        )
                    }
                }

                // MARK: - Finalize and cleanup

                // TODO: make sure output url works well in all cases
                var outputUrl = getSafeUrl(
                    for: target.output,
                    using: fileManager
                )
                if !outputUrl.path().hasPrefix("/") {
                    outputUrl = inputUrl.deletingLastPathComponent()
                        .appending(
                            path: target.output
                        )
                }

                try resetDirectory(at: outputUrl)
                try fileManager.copyRecursively(from: workDirUrl, to: outputUrl)
                try? fileManager.delete(at: workDirUrl)
            }
        }
        catch {
            try? fileManager.delete(at: workDirUrl)
            throw error
        }
    }

}
