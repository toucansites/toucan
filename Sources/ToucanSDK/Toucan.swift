//
//  Toucan.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 04. 17..
//

import FileManagerKit
import Foundation
import Logging
import ToucanCore
import ToucanSerialization
import ToucanSource

private func getSafeURL(
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

    let inputURL: URL
    let targetsToBuild: [String]
    let logger: Logger

    let fileManager: FileManagerKit
    //    let markdownParser: MarkdownParser
    let encoder: ToucanEncoder
    let decoder: ToucanDecoder

    // MARK: - Lifecycle

    /// Initialize a new instance.
    /// - Parameters:
    ///   - input: The input url as a path string.
    ///   - targetsToBuild: The list of target names to build.
    ///   - logger: A logger instance for logging. Defaults to a logger labeled "toucan".
    public init(
        input: String,
        targetsToBuild: [String] = [],
        logger: Logger = .init(label: "toucan")
    ) {
        self.fileManager = FileManager.default
        self.encoder = ToucanYAMLEncoder()
        self.decoder = ToucanYAMLDecoder()
        self.inputURL = getSafeURL(for: input, using: fileManager)
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
            url: inputURL,
            locations:
                fileManager
                .find(
                    name: "toucan",
                    extensions: ["yml", "yaml"],
                    at: inputURL
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
    public func generate(
        now: Date = .init()
    ) throws {
        let workDirURL = try prepareWorkingDirectory()

        do {
            let targetConfig = try loadTargetConfig()
            let activeBuildTargets = getActiveBuildTargets(targetConfig)

            for target in activeBuildTargets {
                logger.info(
                    "Building target: \(target.name)",
                    metadata: [:]
                )

                let buildTargetSourceLoader = BuildTargetSourceLoader(
                    sourceURL: inputURL,
                    target: target,
                    fileManager: fileManager,
                    encoder: encoder,
                    decoder: decoder,
                    logger: logger
                )

                let buildTargetSource = try buildTargetSourceLoader.load()

                let validator = BuildTargetSourceValidator(
                    buildTargetSource: buildTargetSource
                )
                try validator.validate()

                let generatorInfo = GeneratorInfo.current
                var renderer = BuildTargetSourceRenderer(
                    buildTargetSource: buildTargetSource,
                    generatorInfo: generatorInfo,
                    logger: logger
                )

                let templateLoader = TemplateLoader(
                    locations: buildTargetSource.locations,

                    fileManager: fileManager,
                    encoder: encoder,
                    decoder: decoder,
                    logger: logger
                )

                let results = try renderer.render(now: now) {
                    pipeline,
                    contextBundles in
                    switch pipeline.engine.id {
                    case "json":
                        let renderer = ContextBundleToJSONRenderer(
                            pipeline: pipeline,
                            logger: logger
                        )
                        return renderer.render(contextBundles)
                    case "mustache":
                        let template = try templateLoader.load()

                        let templateValidator = try TemplateValidator(
                            generatorInfo: generatorInfo
                        )
                        try templateValidator.validate(template)

                        let renderer = try ContextBundleToHTMLRenderer(
                            pipeline: pipeline,
                            templates: template.getTemplatesIDsWithContents(),
                            logger: logger
                        )
                        return renderer.render(contextBundles)
                    default:
                        throw BuildTargetSourceRendererError.invalidEngine(
                            pipeline.engine.id
                        )
                    }
                }

                try resetDirectory(at: workDirURL)

                // MARK: - Copy default assets

                let copyManager = CopyManager(
                    fileManager: fileManager,
                    sources: [
                        buildTargetSource.locations.currentTemplateAssetsURL,
                        buildTargetSource.locations
                            .currentTemplateAssetOverridesURL,
                        buildTargetSource.locations.siteAssetsURL,
                    ],
                    destination: workDirURL
                )
                try copyManager.copy()

                // MARK: - Writing results

                for result in results {
                    let destinationFolder = workDirURL.appending(
                        path: result.destination.path
                    )
                    try fileManager.createDirectory(at: destinationFolder)

                    let resultOutputURL =
                        destinationFolder
                        .appending(path: result.destination.file)
                        .appendingPathExtension(result.destination.ext)

                    switch result.source {
                    case let .assetFile(path):
                        let srcURL = buildTargetSource.locations.contentsURL
                            .appending(path: path)
                        try fileManager.copy(from: srcURL, to: resultOutputURL)
                    case let .asset(string), let .content(string):
                        try string.write(
                            to: resultOutputURL,
                            atomically: true,
                            encoding: .utf8
                        )
                    }
                }

                // MARK: - Finalize and cleanup

                var outputURL = getSafeURL(
                    for: target.output,
                    using: fileManager
                )
                if !outputURL.path().hasPrefix("/") {
                    outputURL =
                        inputURL
                        .deletingLastPathComponent()
                        .appendingPathIfPresent(target.output)
                }

                try resetDirectory(at: outputURL)
                try fileManager.copyRecursively(from: workDirURL, to: outputURL)
                try? fileManager.delete(at: workDirURL)
            }
        }
        catch {
            try? fileManager.delete(at: workDirURL)
            throw error
        }
    }
}
