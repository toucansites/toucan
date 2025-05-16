//
//  Toucan.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 04. 17..
//

import Foundation
import FileManagerKit
import Logging
import ToucanFileSystem

import ToucanModels
import ToucanSerialization

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
    let frontMatterParser: FrontMatterParser
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
        self.frontMatterParser = FrontMatterParser(
            decoder: decoder,
            logger: logger
        )

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

    func getActiveBuildTargets(_ targets: TargetConfig) -> [Target] {
        // TODO: support --targets flag
        var buildTargets = targets.targets.filter {
            targetsToBuild.contains($0.name)
        }
        if buildTargets.isEmpty {
            buildTargets.append(targets.default)
        }
        return buildTargets
    }

    // MARK: - api

    /// generates the static site
    public func generate() throws {
        let workDirUrl = try prepareWorkingDirectory()

        do {
            let targetConfig = try loadTargetConfig()
            let buildTargets = getActiveBuildTargets(targetConfig)

            for target in buildTargets {
                logger.info(
                    "Building target: \(target.name)",
                    metadata: [
                        "target.name": "\(target.name)",
                        "target.config": "\(target.config)",
                        "target.locale": "\(target.locale)",
                        "target.timeZone": "\(target.timeZone)",
                        "target.default": "\(target.isDefault)",
                        "target.output": "\(target.output)",
                    ]
                )

                let sourceLoader = SourceLoader(
                    sourceUrl: inputUrl,
                    target: target,
                    fileManager: fileManager,
                    frontMatterParser: frontMatterParser,
                    encoder: encoder,
                    decoder: decoder,
                    logger: logger
                )

                let sourceBundle = try sourceLoader.load()

                // MARK: - Validation

                /// Validate site locale
                validate(
                    .init(
                        locale: target.locale,
                        timeZone: target.timeZone,
                        format: ""
                    )
                )

                /// Validate config date formats
                validate(sourceBundle.config.dateFormats.input)
                for dateFormat in sourceBundle.sourceConfig.config.dateFormats
                    .output.values
                {
                    validate(dateFormat)
                }

                /// Validate pipeline date formats
                for pipeline in sourceBundle.pipelines {
                    for dateFormat in pipeline.dataTypes.date.dateFormats.values
                    {
                        validate(dateFormat)
                    }
                }

                /// Validate slugs
                try validateSlugs(sourceBundle)

                /// Validate frontMatters
                validateFrontMatters(sourceBundle)

                // MARK: - Render pipeline results

                var renderer = SourceBundleRenderer(
                    sourceBundle: sourceBundle,
                    fileManager: fileManager,
                    logger: logger
                )

                let results = try renderer.render(now: Date())

                // MARK: - Preparing work dir

                try resetDirectory(at: workDirUrl)

                // MARK: - Copy default assets

                let copyManager = CopyManager(
                    fileManager: fileManager,
                    sources: [
                        sourceBundle.sourceConfig.currentThemeAssetsUrl,
                        sourceBundle.sourceConfig.currentThemeOverrideAssetsUrl,
                        sourceBundle.sourceConfig.siteAssetsUrl,
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
                        let srcUrl = sourceBundle.sourceConfig.contentsUrl
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

    func validate(_ dateFormat: LocalizedDateFormat) {
        if let value = dateFormat.locale {
            let canonicalId = Locale.identifier(.icu, from: value)

            if !Locale.availableIdentifiers.contains(canonicalId) {
                logger.warning("Invalid site locale: \(value)")
            }
        }
        if let value = dateFormat.timeZone, TimeZone(identifier: value) == nil {
            logger.warning("Invalid site time zone: \(value)")
        }
    }

    func validateSlugs(_ sourceBundle: SourceBundle) throws {
        let slugs = sourceBundle.contents.map(\.slug.value)
        let duplicatedSlugs = Dictionary(grouping: slugs, by: { $0 })
            .mapValues { $0.count }
            .filter { $1 > 1 }

        if !duplicatedSlugs.isEmpty {
            throw Error.duplicateSlugs(duplicatedSlugs.keys.map { String($0) })
        }
    }

    func validateFrontMatters(_ sourceBundle: SourceBundle) {
        for content in sourceBundle.contents {
            let metadata: Logger.Metadata = ["slug": "\(content.slug.value)"]
            let frontMatter = content.rawValue.frontMatter

            let missingProperties = content.definition.properties
                .filter { name, property in
                    property.required && frontMatter[name] == nil
                        && property.default?.value == nil
                }

            for name in missingProperties.keys {
                logger.warning(
                    "Missing content property: `\(name)`",
                    metadata: metadata
                )
            }

            let missingRelations = content.definition.relations.keys.filter {
                frontMatter[$0] == nil
            }

            for name in missingRelations {
                logger.warning(
                    "Missing content relation: `\(name)`",
                    metadata: metadata
                )
            }
        }
    }
}
