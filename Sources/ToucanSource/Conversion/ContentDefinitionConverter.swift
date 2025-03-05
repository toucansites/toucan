//
//  File.swift
//  toucan
//
//  Created by Tibor Bodecs on 2025. 02. 21..
//

import Foundation
import ToucanModels
import Logging

public struct ContentDefinitionConverter {

    let contentDefinition: ContentDefinition
    let dateFormatter: DateFormatter
    let defaultDateFormat: String

    let logger: Logger

    public init(
        contentDefinition: ContentDefinition,
        dateFormatter: DateFormatter,
        defaultDateFormat: String,
        logger: Logger
    ) {
        self.contentDefinition = contentDefinition
        self.dateFormatter = dateFormatter
        self.defaultDateFormat = defaultDateFormat
        self.logger = logger
    }

    public func convert(rawContent: RawContent) -> Content {
        var properties: [String: AnyCodable] = [:]
        for (key, property) in contentDefinition.properties {
            let rawValue = rawContent.frontMatter[key]
            let converter = PropertConverter(
                property: property,
                dateFormatter: dateFormatter,
                defaultDateFormat: defaultDateFormat,
                logger: logger
            )

            properties[key] = converter.convert(rawValue: rawValue, forKey: key)
        }

        var relations: [String: RelationValue] = [:]
        for (key, relation) in contentDefinition.relations {
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

        let keysToRemove =
            ["id", "type", "slug"]
            + contentDefinition.properties.keys
            + contentDefinition.relations.keys

        var userDefined = rawContent.frontMatter
        for key in keysToRemove {
            userDefined.removeValue(forKey: key)
        }

        var id: String =
            rawContent.origin.path
            .split(separator: "/")
            .last
            .map(String.init) ?? ""

        let rawId = rawContent.frontMatter["id"]?.value as? String

        if let rawId, !rawId.isEmpty {
            id = rawId
        }

        var slug: String = rawContent.origin.slug
        let rawSlug = rawContent.frontMatter["slug"]?.value as? String

        if let rawSlug, !rawSlug.isEmpty {
            slug = rawSlug
        }

        return .init(
            id: id,
            slug: slug,
            rawValue: rawContent,
            definition: contentDefinition,
            properties: properties,
            relations: relations,
            userDefined: userDefined
        )
    }
}
