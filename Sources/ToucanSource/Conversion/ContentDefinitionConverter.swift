//
//  ContentDefinitionConverter.swift
//  Toucan
//
//  Created by Tibor Bodecs on 2025. 02. 21..
//

import Foundation
import ToucanModels
import Logging

/// Converts a `RawContent` instance into a structured `Content` object using a given content definition.
public struct ContentDefinitionConverter {

    // MARK: - Properties

    /// The content definition that describes the schema for this content type.
    let contentDefinition: ContentDefinition

    /// The date formatter used for parsing date-type properties.
    let dateFormatter: DateFormatter

    /// The default localized date format (based on the formatter settings).
    let defaultDateFormat: LocalizedDateFormat

    /// Logger for warnings or errors during conversion.
    let logger: Logger

    // MARK: - Initialization

    /// Creates a new converter with the given content definition and formatter.
    ///
    /// - Parameters:
    ///   - contentDefinition: The schema describing expected fields and relations.
    ///   - dateFormatter: A `DateFormatter` preconfigured for parsing dates.
    ///   - logger: Logger for diagnostics during the conversion process.
    public init(
        contentDefinition: ContentDefinition,
        dateFormatter: DateFormatter,
        logger: Logger
    ) {
        self.contentDefinition = contentDefinition
        self.dateFormatter = dateFormatter
        self.defaultDateFormat = .init(
            locale: dateFormatter.locale.identifier,
            timeZone: dateFormatter.timeZone.identifier,
            format: dateFormatter.dateFormat!
        )
        self.logger = logger
    }

    // MARK: - Content Conversion

    /// Converts a `RawContent` structure into a validated and normalized `Content` object.
    ///
    /// This includes:
    /// - Converting all defined properties using `PropertyConverter`
    /// - Resolving content relations (`.one` or `.many`)
    /// - Extracting remaining user-defined front matter
    /// - Normalizing the `id` and `slug` values
    ///
    /// - Parameter rawContent: The raw content input to convert.
    /// - Returns: A fully structured `Content` object.
    public func convert(rawContent: RawContent) -> Content {
        var properties: [String: AnyCodable] = [:]

        // Convert schema-defined properties
        for (key, property) in contentDefinition.properties.sorted(by: {
            $0.key < $1.key
        }) {
            dateFormatter.config(with: defaultDateFormat)
            let rawValue = rawContent.frontMatter[key]
            let converter = PropertyConverter(
                property: property,
                dateFormatter: dateFormatter,
                logger: logger
            )
            properties[key] = converter.convert(
                rawValue: rawValue,
                forKey: key
            )
        }

        // Convert schema-defined relations
        var relations: [String: RelationValue] = [:]
        for (key, relation) in contentDefinition.relations.sorted(by: {
            $0.key < $1.key
        }) {
            let rawValue = rawContent.frontMatter[key]
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

        var userDefined = rawContent.frontMatter
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

        if let rawId = rawContent.frontMatter.string("id") {
            id = rawId
        }

        // Extract `slug` from front matter or fallback to origin slug
        var slug: String = rawContent.origin.slug
        if let rawSlug = rawContent.frontMatter.string(
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
}
