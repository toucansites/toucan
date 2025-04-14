//
//  ContentDefinitionConverter.swift
//  Toucan
//
//  Created by Tibor Bodecs on 2025. 02. 21..
//

import Foundation
import ToucanModels
import Logging

public struct ContentDefinitionConverter {

    let contentDefinition: ContentDefinition
    let dateFormatter: DateFormatter
    let defaultDateFormat: LocalizedDateFormat

    let logger: Logger

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

    public func convert(rawContent: RawContent) -> Content {
        var properties: [String: AnyCodable] = [:]

        for (key, property) in contentDefinition.properties.sorted(by: {
            $0.key < $1.key
        }) {
            dateFormatter.config(with: defaultDateFormat)
            let rawValue = rawContent.frontMatter[key]
            let converter = PropertyConverter(
                property: property,
                dateFormatter: dateFormatter,
                defaultDateFormat: defaultDateFormat,
                logger: logger
            )

            properties[key] = converter.convert(
                rawValue: rawValue,
                forKey: key
            )
        }

        var relations: [String: RelationValue] = [:]
        for (key, relation) in contentDefinition.relations.sorted(by: {
            $0.key < $1.key
        }) {

            let rawValue = rawContent.frontMatter[key]
            var identifiers: AnyCodable? = nil

            switch relation.type {
            case .one:
                if let id = rawValue?.value as? String {
                    identifiers = .init(id)
                }
                else if let id = rawValue?.value as? Int {
                    identifiers = .init(id)
                }
                else if let id = rawValue?.value as? Double {
                    identifiers = .init(id)
                }
            case .many:
                if let ids = rawValue?.value as? [String] {
                    identifiers = .init(ids.map { $0 })
                }
                if let ids = rawValue?.value as? [Int] {
                    identifiers = .init(ids.map { $0 })
                }
                if let ids = rawValue?.value as? [Double] {
                    identifiers = .init(ids.map { $0 })
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
            .dropLast()
            .last
            .map(String.init) ?? ""

        if let rawId = rawContent.frontMatter.string("id") {
            id = rawId
        }

        var slug: String = rawContent.origin.slug
        if let rawSlug = rawContent.frontMatter.string(
            "slug",
            allowingEmptyValue: true
        ) {
            slug = rawSlug
        }

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
