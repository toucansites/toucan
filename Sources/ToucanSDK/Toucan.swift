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
import ToucanTesting
import ToucanSource
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
    let fs: ToucanFileSystem
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
        self.fs = ToucanFileSystem(fileManager: fileManager)
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
        logger.debug("Working at: `\(workDirUrl.absoluteString)`")

        do {

            let targetsLoader = TargetsLoader(
                url: inputUrl,
                fileName: "toucan.yml",
                decoder: decoder,
                logger: logger
            )

            let targets = try targetsLoader.load()

            // TODO: support --targets flag
            var buildTargets = targets.all.filter {
                targetsToBuild.contains($0.name)
            }

            if buildTargets.isEmpty {
                buildTargets.append(targets.all[0])
            }

            for target in buildTargets {
                logger.info(
                    "Building target: \(target.name)",
                    metadata: [
                        "target.name": "\(target.name)",
                        "target.config": "\(target.config)",
                        "target.locale": "\(target.locale ?? "nil")",
                        "target.timeZone": "\(target.timeZone ?? "nil")",
                        "target.default": "\(target.isDefault)",
                        "target.output": "\(target.output)",
                    ]
                )

                let outputUrl = getSafeUrl(
                    for: target.output,
                    using: fileManager
                )

                let sourceLoader = SourceLoader(
                    sourceUrl: inputUrl,
                    baseUrl: target.url,
                    fileManager: fileManager,
                    fs: fs,
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
                        locale: sourceBundle.settings.locale,
                        timeZone: sourceBundle.settings.timeZone,
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

                let assetsWriter = AssetsWriter(
                    fileManager: fileManager,
                    sourceConfig: sourceBundle.sourceConfig,
                    workDirUrl: workDirUrl
                )
                try assetsWriter.copyDefaultAssets()

                // MARK: - Writing results

                for result in results {
                    let destinationFolder = workDirUrl.appending(
                        path: result.destination.path
                    )
                    try fileManager.createDirectory(at: destinationFolder)

                    let outputUrl =
                        destinationFolder
                        .appending(path: result.destination.file)
                        .appendingPathExtension(result.destination.ext)

                    switch result.source {
                    case .assetFile(let path):
                        let srcUrl = sourceBundle.sourceConfig.contentsUrl
                            .appending(path: path)
                        try fileManager.copy(from: srcUrl, to: outputUrl)
                    case .asset(let string), .content(let string):
                        try string.write(
                            to: outputUrl,
                            atomically: true,
                            encoding: .utf8
                        )
                    }
                }

                // MARK: - Finalize and cleanup

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
