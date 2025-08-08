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

/// Primary entry point for generating a static site using the Toucan framework.
public struct Toucan {

    let fileManager: FileManagerKit
    let encoder: ToucanEncoder
    let decoder: ToucanDecoder
    let logger: Logger

    /// Initialize a new instance.
    ///
    /// - Parameters:
    ///   - fileManager: The file manager used to perform file operations.
    ///   - encoder: The encoder used to encode data. Defaults to a YAML encoder.
    ///   - decoder: The decoder used to decode data. Defaults to a YAML decoder.
    ///   - logger: A logger instance for logging. Defaults to a logger labeled "toucan".
    public init(
        fileManager: FileManagerKit = FileManager.default,
        encoder: ToucanEncoder = ToucanYAMLEncoder(),
        decoder: ToucanDecoder = ToucanYAMLDecoder(),
        logger: Logger = .subsystem()
    ) {
        self.fileManager = fileManager
        self.encoder = encoder
        self.decoder = decoder
        self.logger = logger
    }

    func resolveHomeURL(
        for path: String
    ) -> URL {
        let home = fileManager.homeDirectoryForCurrentUser.path
        return
            .init(
                fileURLWithPath: path.replacingOccurrences(["~": home])
            )
            .standardized
    }

    func absoluteURL(
        for path: String,
        cwd: String? = nil
    ) -> URL {
        if path.hasPrefix("/") {
            return URL(filePath: path).standardized
        }
        if path.hasPrefix("~") {
            return resolveHomeURL(for: path).standardized
        }
        let cwd = cwd ?? fileManager.currentDirectoryPath
        let cwdURL = URL(filePath: cwd)
        if path == "." || path == "./" {
            return cwdURL.standardized
        }
        return cwdURL.appendingPathIfPresent(path).standardized
    }

    func resetDirectory(at url: URL) throws {
        if fileManager.exists(at: url) {
            try fileManager.delete(at: url)
        }
        try fileManager.createDirectory(
            at: url,
            attributes: nil
        )
    }

    func prepareTemporaryWorkingDirectory() throws -> URL {
        let url = fileManager
            .temporaryDirectory
            .appendingPathComponent("toucan")
            .appendingPathComponent(UUID().uuidString)

        try resetDirectory(at: url)

        logger.debug(
            "Working at temporary directory.",
            metadata: [
                "path": .string(url.path())
            ]
        )

        return url
    }

    func loadTargetConfig(
        workDirURL: URL
    ) throws -> TargetConfig {
        try ObjectLoader(
            url: workDirURL,
            locations:
                fileManager
                .find(
                    name: "toucan",
                    extensions: ["yml", "yaml"],
                    at: workDirURL
                ),
            encoder: encoder,
            decoder: decoder
        )
        .load(TargetConfig.self)
    }

    func getActiveBuildTargets(
        targetConfig: TargetConfig,
        targetsToBuild: [String]
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

    /// Generates the static site.
    ///
    /// - Parameters:
    ///   - workDir: The working directory URL as a path string.
    ///   - targetsToBuild: The list of target names to build.
    ///   - now: The current date used during the build.
    /// - Throws: An error if the generation fails.
    public func generate(
        workDir: String,
        targetsToBuild: [String] = [],
        now: Date = .init()
    ) throws {
        let workDirURL = absoluteURL(for: workDir)
        let temporaryWorkDirURL = try prepareTemporaryWorkingDirectory()

        do {
            let targetConfig = try loadTargetConfig(
                workDirURL: workDirURL
            )
            let activeBuildTargets = getActiveBuildTargets(
                targetConfig: targetConfig,
                targetsToBuild: targetsToBuild
            )

            for target in activeBuildTargets {
                let sourceURL = absoluteURL(
                    for: target.input,
                    cwd: workDirURL.path()
                )
                let distURL = absoluteURL(
                    for: target.output,
                    cwd: workDirURL.path()
                )

                logger.debug(
                    "Building target.",
                    metadata: [
                        "name": .string(target.name),
                        "workDir": .string(workDirURL.path()),
                        "srcDir": .string(sourceURL.path()),
                        "distDir": .string(distURL.path()),
                        "tmpDir": .string(temporaryWorkDirURL.path()),
                    ]
                )

                let buildTargetSourceLoader = BuildTargetSourceLoader(
                    sourceURL: workDirURL,
                    target: target,
                    fileManager: fileManager,
                    encoder: encoder,
                    decoder: decoder
                )

                let buildTargetSource = try buildTargetSourceLoader.load()

                let validator = BuildTargetSourceValidator(
                    buildTargetSource: buildTargetSource
                )
                try validator.validate()

                let generatorInfo = GeneratorInfo.current
                var renderer = BuildTargetSourceRenderer(
                    buildTargetSource: buildTargetSource,
                    generatorInfo: generatorInfo
                )

                let templateLoader = TemplateLoader(
                    locations: buildTargetSource.locations,

                    fileManager: fileManager,
                    encoder: encoder,
                    decoder: decoder
                )

                let results = try renderer.render(
                    now: now
                ) { pipeline, contextBundles in

                    logger.trace(
                        "Rendering pipeline",
                        metadata: [
                            "id": .string(pipeline.id),
                            "contextBundleCount": .string(
                                String(contextBundles.count)
                            ),
                        ]
                    )

                    switch pipeline.engine.id {
                    case "json":
                        let renderer = ContextBundleToJSONRenderer(
                            pipeline: pipeline,
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
                            templates: template.getViewIDsWithContents(),
                        )
                        return renderer.render(contextBundles)
                    default:
                        throw BuildTargetSourceRendererError.invalidEngine(
                            pipeline.engine.id
                        )
                    }
                }

                logger.debug(
                    "Target ready.",
                    metadata: [
                        "name": .string(target.name),
                        "resultsCount": .string(String(results.count)),
                    ]
                )

                try resetDirectory(at: temporaryWorkDirURL)

                // MARK: - Copy default assets

                let copyManager = CopyManager(
                    fileManager: fileManager,
                    sources: [
                        buildTargetSource.locations.currentTemplateAssetsURL,
                        buildTargetSource.locations
                            .currentTemplateAssetOverridesURL,
                        buildTargetSource.locations.siteAssetsURL,
                    ],
                    destination: temporaryWorkDirURL
                )
                try copyManager.copy()

                // MARK: - Writing results

                for result in results {
                    let destinationFolder =
                        temporaryWorkDirURL
                        .appendingPathIfPresent(result.destination.path)

                    try fileManager.createDirectory(
                        at: destinationFolder,
                        attributes: nil
                    )

                    let resultOutputURL =
                        destinationFolder
                        .appendingPathIfPresent(result.destination.file)
                        .appendingPathExtension(result.destination.ext)

                    switch result.source {
                    case let .assetFile(path):
                        let srcURL = buildTargetSource.locations.contentsURL
                            .appendingPathIfPresent(path)
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

                try resetDirectory(at: distURL)
                try fileManager.copyRecursively(
                    from: temporaryWorkDirURL,
                    to: distURL
                )
                try fileManager.delete(at: temporaryWorkDirURL)
            }
        }
        catch {
            try fileManager.delete(at: temporaryWorkDirURL)
            throw error
        }
    }

    /// Attempts to generate the static site and logs any errors encountered.
    /// - Parameters:
    ///   - workDir: The working directory URL as a path string.
    ///   - targetsToBuild: The list of target names to build.
    ///   - now: The current date used during the build.
    /// - Returns: `true` if generation succeeds without errors; otherwise, `false`.
    ///
    @discardableResult
    public func generateAndLogErrors(
        workDir: String,
        targetsToBuild: [String],
        now: Date
    ) -> Bool {
        do {
            try generate(
                workDir: workDir,
                targetsToBuild: targetsToBuild,
                now: now
            )
            return true
        }
        catch let error as ToucanError {
            logger.error("\(error.logMessageStack())")
        }
        catch {
            logger.error("\(error)")
        }
        return false
    }
}
