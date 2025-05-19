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

public struct SourceLoader {

    let sourceUrl: URL
    let target: Target

    let fileManager: FileManagerKit
    let markdownParser: MarkdownParser

    let encoder: ToucanEncoder
    let decoder: ToucanDecoder

    let logger: Logger

    // MARK: -

    public init(
        sourceUrl: URL,
        target: Target,
        fileManager: FileManagerKit,
        markdownParser: MarkdownParser,
        encoder: ToucanEncoder,
        decoder: ToucanDecoder,
        logger: Logger = .subsystem("source-loader")
    ) {
        self.sourceUrl = sourceUrl
        self.target = target
        self.fileManager = fileManager
        self.markdownParser = markdownParser
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
    public func load() throws -> BuildTargetSource {

        let configUrl = sourceUrl.appendingPathIfPresent(target.config)

        let config = try load(
            type: Config.self,
            named: "config",
            at: configUrl
        )

        let locations = SourceLocations(
            sourceUrl: sourceUrl,
            config: config
        )

        let settings = try load(
            type: Settings.self,
            named: "site",
            at: locations.siteSettingsURL
        )

        let pipelines = try load(
            type: Pipeline.self,
            at: locations.pipelinesUrl
        )

        let loadedTypes = try load(
            type: ContentDefinition.self,
            at: locations.typesUrl
        )
        let virtualTypes = pipelines.compactMap {
            $0.definesType ? ContentDefinition(id: $0.id) : nil
        }
        let finalTypes = loadedTypes + virtualTypes

        let blockDirectives = try load(
            type: Block.self,
            at: locations.blocksUrl
        )

        let rawContentsLoader = RawContentLoader(
            locations: .init(sourceUrl: sourceUrl, config: config),
            decoder: .init(),
            markdownParser: .init(decoder: decoder),
            fileManager: fileManager,
            logger: logger
        )
        let rawContents = try rawContentsLoader.load()

        return .init(
            location: sourceUrl,
            target: target,
            config: config,
            settings: settings,
            pipelines: pipelines,
            contentDefinitions: finalTypes,
            rawContents: rawContents,
            blockDirectives: blockDirectives
        )
    }

    func load<T: Codable>(
        type: T.Type,
        named name: String,
        at url: URL
    ) throws -> T {
        try ObjectLoader(
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

    func load<T: Decodable>(
        type: T.Type,
        at url: URL
    ) throws -> [T] {
        try ObjectLoader(
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
