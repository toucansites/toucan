//
//  File.swift
//  toucan
//
//  Created by Tibor Bödecs on 2025. 05. 21..
//

import Foundation
import ToucanSource
import ToucanSerialization
import Logging

struct ContentConverter {

    enum Failure: Error {
        case noExplicitContentDefinitionFound(String)
        case noDefaultContentDefinitionFound
        case multipleDefaultContentDefinitionsFound
    }

    let sourceBundle: BuildTargetSource
    let encoder: ToucanEncoder
    let decoder: ToucanDecoder
    let dateFormatter: DateFormatter
    let defaultDateFormat: LocalizedDateFormat
    let logger: Logger

    init(
        sourceBundle: BuildTargetSource,
        encoder: ToucanEncoder,
        decoder: ToucanDecoder,
        logger: Logger
    ) {
        self.sourceBundle = sourceBundle
        self.encoder = encoder
        self.decoder = decoder
        self.logger = logger

        self.dateFormatter = sourceBundle.target.dateFormatter(
            sourceBundle.config.dateFormats.input
        )

        self.defaultDateFormat = .init(
            locale: dateFormatter.locale.identifier,
            timeZone: dateFormatter.timeZone.identifier,
            format: dateFormatter.dateFormat!
        )
    }

    func convert(
        rawContents: [RawContent]
    ) throws -> [Content] {
        try rawContents.map { try convert(rawContent: $0) }
    }

    func convert(
        rawContent: RawContent
    ) throws -> Content {
        let type = rawContent.markdown.frontMatter.string("type")

        let contentDefinition = try detectContentType(
            explicitType: type,
            origin: rawContent.origin
        )

        var properties: [String: AnyCodable] = [:]

        // Convert schema-defined properties
        for (key, property) in contentDefinition.properties.sorted(by: {
            $0.key < $1.key
        }) {
            dateFormatter.config(with: defaultDateFormat)
            let rawValue = rawContent.markdown.frontMatter[key]

            properties[key] = convert(
                property: property,
                rawValue: rawValue,
                forKey: key
            )
        }

        // Convert schema-defined relations
        var relations: [String: RelationValue] = [:]
        for (key, relation) in contentDefinition.relations.sorted(by: {
            $0.key < $1.key
        }) {
            let rawValue = rawContent.markdown.frontMatter[key]
            var identifiers: [String] = []

            switch relation.type {
            case .one:
                if let id = rawValue?.value as? String {
                    identifiers.append(id)
                }
            case .many:
                if let ids = rawValue?.value as? [String] {
                    identifiers.append(contentsOf: ids)
                }
            }

            relations[key] = .init(
                contentType: relation.references,
                type: relation.type,
                identifiers: identifiers
            )
        }

        // Filter out reserved keys and schema-mapped fields to extract user-defined fields
        let keysToRemove =
            ["id", "type", "slug"]
            + contentDefinition.properties.keys
            + contentDefinition.relations.keys

        var userDefined = rawContent.markdown.frontMatter
        for key in keysToRemove {
            userDefined.removeValue(forKey: key)
        }

        // Extract `id` from front matter or fallback from origin path
        var id: String =
            rawContent.origin.path
            .split(separator: "/")
            .dropLast()
            .last
            .map(String.init)?
            .trimmingBracketsContent() ?? ""

        if let rawId = rawContent.markdown.frontMatter.string("id") {
            id = rawId
        }

        // Extract `slug` from front matter or fallback to origin slug
        var slug: String = rawContent.origin.slug
        if let rawSlug = rawContent.markdown.frontMatter.string(
            "slug",
            allowingEmptyValue: true
        ) {
            slug = rawSlug
        }

        // Final assembled content object
        return Content(
            id: id,
            slug: .init(value: slug),
            rawValue: rawContent,
            definition: contentDefinition,
            properties: properties,
            relations: relations,
            userDefined: userDefined,
            iteratorInfo: nil
        )
    }

    // Content Definition Detection

    func detectContentType(
        explicitType: String?,
        origin: Origin
    ) throws -> ContentDefinition {
        /// Use explicit content definition if specified
        if let explicitType {
            guard let result = detectExplicitType(explicitType) else {
                //                logger.info("Explicit content type (\(explicitType)) not found")
                throw Failure.noExplicitContentDefinitionFound(explicitType)
            }
            return result
        }

        /// Searching in `paths` values
        if let matchingPathsType = detectMatchingPathsType(origin: origin) {
            return matchingPathsType
        }

        /// Find the default content definition if exists
        return try detectDefaultType()
    }

    func detectExplicitType(_ value: String) -> ContentDefinition? {
        sourceBundle.contentDefinitions.first { $0.id == value }
    }

    func detectMatchingPathsType(
        origin: Origin
    ) -> ContentDefinition? {
        sourceBundle.contentDefinitions.first { definition in
            definition.paths.contains { origin.path.hasPrefix($0) }
        }
    }

    func detectDefaultType() throws -> ContentDefinition {
        let results = sourceBundle.contentDefinitions.filter { $0.default }

        guard !results.isEmpty else {
            //            logger.info("No content type found for slug: \(origin.slug)")
            throw Failure.noDefaultContentDefinitionFound
        }

        guard results.count == 1 else {
            let types = results.map { $0.id }.joined(separator: ", ")
            //            logger.info(
            //                "Multiple content types (\(types)) found for slug: `\(origin.slug)`"
            //            )
            throw Failure.multipleDefaultContentDefinitionsFound
        }

        return results[0]
    }

    func convert(
        property: Property,
        rawValue: AnyCodable?,
        forKey key: String
    ) -> AnyCodable? {
        let value = rawValue ?? property.default

        switch property.type {
        case .date(let dateFormat):
            guard let rawDateValue = value?.value(as: String.self) else {
                logger.warning(
                    "Raw date property is not a string (\(key): \(value?.value ?? "nil"))."
                )
                return nil
            }

            if let dateFormat {
                dateFormatter.config(with: dateFormat)
            }

            guard let value = dateFormatter.date(from: rawDateValue) else {
                logger.warning(
                    "Raw date property value is not a date (\(key): \(rawDateValue))."
                )
                return nil
            }
            return .init(value.timeIntervalSince1970)
        default:
            return value
        }
    }
}
