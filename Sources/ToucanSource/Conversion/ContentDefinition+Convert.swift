//
//  File.swift
//  toucan
//
//  Created by Tibor Bodecs on 2025. 02. 21..
//

import Foundation
import ToucanModels

extension ContentDefinition {

    public func convert(
        rawContent: RawContent,
        definition: ContentDefinition,
        using formatter: DateFormatter
    ) -> Content {

        var properties: [String: AnyCodable] = [:]
        for (key, property) in self.properties {
            let rawValue = rawContent.frontMatter[key]
            let value = property.convert(
                key: key,  // TODO: key is only used for logging.
                rawValue: rawValue,
                using: formatter
            )
            properties[key] = value
        }

        var relations: [String: RelationValue] = [:]
        for (key, relation) in self.relations {
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
            + self.properties.keys
            + self.relations.keys

        var userDefined = rawContent.frontMatter
        for key in keysToRemove {
            userDefined.removeValue(forKey: key)
        }

        var id: String =
            rawContent.origin.path.split(separator: "/").last.map(String.init)
            ?? ""
        if let rawId = rawContent.frontMatter["id"]?.value as? String,
            !rawId.isEmpty
        {
            id = rawId
        }

        var slug: String = rawContent.origin.slug
        if let rawSlug = rawContent.frontMatter["slug"]?.value as? String,
            !rawSlug.isEmpty
        {
            slug = rawSlug
        }

        return .init(
            id: id,
            slug: slug,
            rawValue: rawContent,
            definition: definition,
            properties: properties,
            relations: relations,
            userDefined: userDefined
        )
    }
}
