//
//  SourceLoader.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 04. 04..
//

import Foundation
import Logging
import FileManagerKit
import ToucanCore
import ToucanSerialization

public struct SourceLoaderError: ToucanError {

    let type: String
    let error: Error?

    init(
        type: String,
        error: Error? = nil
    ) {
        self.type = type
        self.error = error
    }

    public var underlyingErrors: [Error] {
        error.map { [$0] } ?? []
    }

    public var logMessage: String {
        "Could not load: `\(type)`."
    }

    public var userFriendlyMessage: String {
        "Could not load source."
    }
}

public struct SourceLoader {

    let sourceUrl: URL
    let target: Target

    let fileManager: FileManagerKit

    let encoder: ToucanEncoder
    let decoder: ToucanDecoder

    let logger: Logger

    // MARK: -

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
    /// - Returns: A `SourceBundle` containing the loaded and processed data.
    /// - Throws: An error if any of the loading operations fail.
    public func load() throws(SourceLoaderError) -> BuildTargetSource {

        let config = try loadConfig()
        let locations = getLocations(using: config)
        let settings = try loadSettings(using: locations)
        let pipelines = try loadPipelines(using: locations)
        let types = try loadTypes(using: locations, pipelines: pipelines)
        let blocks = try loadBlocks(using: locations)
        let rawContents = try loadRawContents(using: config)

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

    private func loadRawContents(
        using config: Config
    ) throws(SourceLoaderError) -> [RawContent] {
        do {
            let rawContentsLoader = RawContentLoader(
                locations: .init(sourceUrl: sourceUrl, config: config),
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

    func getLocations(
        using config: Config
    ) -> SourceLocations {
        .init(
            sourceUrl: sourceUrl,
            config: config
        )
    }

    func loadSettings(
        using locations: SourceLocations
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

    func loadPipelines(
        using locations: SourceLocations
    ) throws(SourceLoaderError) -> [Pipeline] {
        try load(
            type: Pipeline.self,
            at: locations.pipelinesUrl
        )
    }

    func loadTypes(
        using locations: SourceLocations,
        pipelines: [Pipeline]
    ) throws(SourceLoaderError) -> [ContentDefinition] {
        let loadedTypes = try load(
            type: ContentDefinition.self,
            at: locations.typesUrl
        )
        let virtualTypes = pipelines.compactMap {
            $0.definesType ? ContentDefinition(id: $0.id) : nil
        }
        return (loadedTypes + virtualTypes).sorted(by: { $0.id < $1.id })
    }

    func loadBlocks(
        using locations: SourceLocations
    ) throws(SourceLoaderError) -> [Block] {
        try load(
            type: Block.self,
            at: locations.blocksUrl
        )
    }
}

// MARK: - Create Contents from RawContents

//        let contents: [Content] = try rawContents.compactMap {
//            /// If this is slow or overkill we can still use $0.frontMatter["type"], maybe with a Keys enum?
//            let rawReservedFrontMatter = try encoder.encode($0.frontMatter)
//            let reservedFrontMatter = try decoder.decode(
//                ReservedFrontMatter.self,
//                from: rawReservedFrontMatter.data(using: .utf8)!
//            )
//
//            let detector = ContentDefinitionDetector(
//                definitions: contentDefinitions,
//                origin: $0.origin,
//                logger: logger
//            )
//
//            let contentDefinition = try detector.detect(
//                explicitType: reservedFrontMatter.type
//            )
//
//            let contentDefinitionConverter = ContentDefinitionConverter(
//                contentDefinition: contentDefinition,
//                dateFormatter: target.dateFormatter(config.dateFormats.input),
//                logger: logger
//            )
//
//            return contentDefinitionConverter.convert(rawContent: $0)
//        }
