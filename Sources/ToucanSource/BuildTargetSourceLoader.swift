//
//  BuildTargetSourceLoader.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 04. 04..
//

import Foundation
import Logging
import FileManagerKit
import ToucanCore
import ToucanSerialization

/// Loads and processes various parts of a build target's source bundle.
///
/// Uses dependency-injected tools to fetch, decode, and construct structured data from source files.
public struct BuildTargetSourceLoader {

    /// The URL of the root source directory.
    var sourceUrl: URL
    /// Metadata describing the current build target.
    var target: Target

    /// A utility for accessing and searching the file system.
    var fileManager: FileManagerKit

    /// Encoder and decoder for serializing and deserializing content.
    var encoder: ToucanEncoder
    var decoder: ToucanDecoder

    /// Logger instance for emitting structured debug information.
    var logger: Logger

    // MARK: -

    /// Initializes a new instance of `BuildTargetSourceLoader`.
    ///
    /// - Parameters:
    ///   - sourceUrl: The root directory containing source files.
    ///   - target: The build target metadata.
    ///   - fileManager: File system access helper.
    ///   - encoder: The encoder used for serialization.
    ///   - decoder: The decoder used for deserialization.
    ///   - logger: Optional logger for debugging and diagnostics.
    public init(
        sourceUrl: URL,
        target: Target,
        fileManager: FileManagerKit,
        encoder: ToucanEncoder,
        decoder: ToucanDecoder,
        logger: Logger = .subsystem("source-loader")
    ) {
        self.sourceUrl = sourceUrl
        self.target = target
        self.fileManager = fileManager
        self.encoder = encoder
        self.decoder = decoder
        self.logger = logger
    }

    /// Loads and processes source content from the specified source URL.
    /// This function retrieves configuration, settings, content definitions, block directives,
    /// and raw contents, then transforms them into structured content.
    ///
    /// - Returns: A `BuildTargetSource` containing the loaded and processed data.
    /// - Throws: An error if any of the loading operations fail.
    public func load() throws(SourceLoaderError) -> BuildTargetSource {

        let config = try loadConfig()
        let locations = getLocations(using: config)
        let settings = try loadSettings(using: locations)
        let pipelines = try loadPipelines(using: locations)
        let types = try loadTypes(using: locations)
        let blocks = try loadBlocks(using: locations)
        let rawContents = try loadRawContents(using: config)

        #warning("move locations inside config, use that everywhere")
        return .init(
            location: sourceUrl,
            target: target,
            config: config,
            settings: settings,
            pipelines: pipelines,
            contentDefinitions: types,
            rawContents: rawContents,
            blockDirectives: blocks
        )
    }

    /// Loads raw contents from the source using the provided configuration.
    ///
    /// - Parameter config: The configuration object used to determine content locations.
    /// - Returns: An array of `RawContent` objects.
    /// - Throws: A `SourceLoaderError` if loading fails.
    private func loadRawContents(
        using config: Config
    ) throws(SourceLoaderError) -> [RawContent] {
        do {
            let locations = BuiltTargetSourceLocations(
                sourceUrl: sourceUrl,
                config: config
            )
            let rawContentsLoader = RawContentLoader(
                contentsURL: locations.contentsUrl,
                assetsPath: config.contents.assets.path,
                decoder: .init(),
                markdownParser: .init(decoder: decoder),
                fileManager: fileManager,
                logger: logger
            )
            return try rawContentsLoader.load()
        }
        catch {
            throw .init(type: "RawContent", error: error)
        }
    }

    /// Loads a single Codable object of the specified type from a named file at a given URL.
    ///
    /// - Parameters:
    ///   - type: The type to decode.
    ///   - name: The name of the file to load.
    ///   - url: The directory URL to search within.
    /// - Returns: An instance of the decoded type.
    /// - Throws: A `SourceLoaderError` if loading or decoding fails.
    private func load<T: Codable>(
        type: T.Type,
        named name: String,
        at url: URL
    ) throws(SourceLoaderError) -> T {
        do {
            return try ObjectLoader(
                url: url,
                locations: fileManager.find(
                    name: name,
                    extensions: ["yml", "yaml"],
                    at: url
                ),
                encoder: encoder,
                decoder: decoder,
                logger: logger
            )
            .load(type)
        }
        catch {
            throw .init(type: "Config", error: error)
        }
    }

    /// Loads an array of Decodable objects of the specified type from YAML files at a given URL.
    ///
    /// - Parameters:
    ///   - type: The type to decode.
    ///   - url: The directory URL to search within.
    /// - Returns: An array of decoded objects.
    /// - Throws: A `SourceLoaderError` if loading or decoding fails.
    private func load<T: Decodable>(
        type: T.Type,
        at url: URL
    ) throws(SourceLoaderError) -> [T] {
        do {
            return try ObjectLoader(
                url: url,
                locations: fileManager.find(
                    extensions: ["yml", "yaml"],
                    at: url
                ),
                encoder: encoder,
                decoder: decoder,
                logger: logger
            )
            .load(type)
        }
        catch {
            throw .init(type: "\(type)", error: error)
        }
    }

    /// Loads the main configuration object from the source.
    ///
    /// - Returns: A `Config` object loaded from the source.
    /// - Throws: A `SourceLoaderError` if loading fails.
    func loadConfig() throws(SourceLoaderError) -> Config {
        do {
            let configUrl = sourceUrl.appendingPathIfPresent(target.config)
            let config = try load(
                type: Config.self,
                named: "config",
                at: configUrl
            )
            return config
        }
        catch {
            throw .init(type: "Config", error: error)
        }
    }

    /// Constructs the locations object based on the configuration.
    ///
    /// - Parameter config: The loaded configuration.
    /// - Returns: A `BuiltTargetSourceLocations` instance.
    func getLocations(
        using config: Config
    ) -> BuiltTargetSourceLocations {
        .init(
            sourceUrl: sourceUrl,
            config: config
        )
    }

    /// Loads the site settings from the specified locations.
    ///
    /// - Parameter locations: The source locations to use.
    /// - Returns: A `Settings` object.
    /// - Throws: A `SourceLoaderError` if loading fails.
    func loadSettings(
        using locations: BuiltTargetSourceLocations
    ) throws(SourceLoaderError) -> Settings {
        do {
            return try load(
                type: Settings.self,
                named: "site",
                at: locations.siteSettingsURL
            )
        }
        catch {
            throw .init(type: "Settings", error: error)
        }
    }

    /// Loads pipeline definitions from the specified locations.
    ///
    /// - Parameter locations: The source locations to use.
    /// - Returns: An array of `Pipeline` objects.
    /// - Throws: A `SourceLoaderError` if loading fails.
    func loadPipelines(
        using locations: BuiltTargetSourceLocations
    ) throws(SourceLoaderError) -> [Pipeline] {
        try load(
            type: Pipeline.self,
            at: locations.pipelinesUrl
        )
        .sorted { $0.id < $1.id }
    }

    /// Loads content types
    ///
    /// - Parameter locations: The source locations to use.
    /// - Returns: An array of `ContentDefinition` objects.
    /// - Throws: A `SourceLoaderError` if loading fails.
    func loadTypes(
        using locations: BuiltTargetSourceLocations
    ) throws(SourceLoaderError) -> [ContentDefinition] {
        try load(
            type: ContentDefinition.self,
            at: locations.typesUrl
        )
        .sorted { $0.id < $1.id }
    }

    /// Loads block directives from the specified locations.
    ///
    /// - Parameter locations: The source locations to use.
    /// - Returns: An array of `Block` objects.
    /// - Throws: A `SourceLoaderError` if loading fails.
    func loadBlocks(
        using locations: BuiltTargetSourceLocations
    ) throws(SourceLoaderError) -> [Block] {
        try load(
            type: Block.self,
            at: locations.blocksUrl
        )
        .sorted { $0.name < $1.name }
    }
}
