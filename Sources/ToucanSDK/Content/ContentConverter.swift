//
//  ContentConverter.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 05. 21..
//

import Foundation
import ToucanCore
import ToucanSource
import ToucanSerialization
import Logging

fileprivate extension String {

    // TODO: this is duplicate -> raw content id?
    func trimmingBracketsContent() -> String {
        var result = ""
        var insideBrackets = false

        let decoded = self.removingPercentEncoding ?? self

        for char in decoded {
            if char == "[" {
                insideBrackets = true
            }
            else if char == "]" {
                insideBrackets = false
            }
            else if !insideBrackets {
                result.append(char)
            }
        }
        return result
    }
}

enum ContentConverterError: ToucanError {

    case missingContentType(String)
    case unknown(Error)

    var underlyingErrors: [any Error] {
        switch self {
        case .unknown(let error):
            return [error]
        default:
            return []
        }
    }

    var logMessage: String {
        switch self {
        case .missingContentType:
            return "Missing content type."
        case .unknown(let error):
            return error.localizedDescription
        }
    }

    var userFriendlyMessage: String {
        switch self {
        case .missingContentType:
            return "Missing content type."
        case .unknown:
            return "Unknown content conversion error."
        }
    }
}

struct ContentConverter {

    var buildTargetSource: BuildTargetSource
    var encoder: ToucanEncoder
    var decoder: ToucanDecoder
    var dateFormatter: ToucanDateFormatter
    var logger: Logger
    private var contentTypes: [ContentDefinition]

    init(
        buildTargetSource: BuildTargetSource,
        encoder: ToucanEncoder,
        decoder: ToucanDecoder,
        dateFormatter: ToucanDateFormatter,
        logger: Logger = .subsystem("content-converter")
    ) {
        self.buildTargetSource = buildTargetSource
        self.encoder = encoder
        self.decoder = decoder
        self.dateFormatter = dateFormatter
        self.logger = logger

        let virtualTypes = buildTargetSource.pipelines.compactMap {
            $0.definesType ? ContentDefinition(id: $0.id) : nil
        }
        self.contentTypes =
            (buildTargetSource.contentDefinitions + virtualTypes)
            .sorted { $0.id < $1.id }
    }

    func convertTargetContents() throws(ContentConverterError) -> [Content] {
        do {
            return try buildTargetSource.rawContents.map {
                try convert(rawContent: $0)
            }
        }
        catch let error as ContentConverterError {
            throw error
        }
        catch {
            throw .unknown(error)
        }
    }

    // MARK: -

    // TODO: throw instead of warning...
    func convert(
        property: Property,
        rawValue: AnyCodable?,
        forKey key: String
    ) -> AnyCodable? {
        let value = rawValue ?? property.default

        switch property.type {
        case .date(let config):
            guard
                let rawDateValue = value?.value(as: String.self)
            else {
                logger.warning(
                    "Date property is not a string (\(key): \(value?.value ?? "nil"))."
                )
                return nil
            }
            guard
                let date = dateFormatter.parse(
                    date: rawDateValue,
                    using: config
                )
            else {
                logger.warning(
                    "Date property is not valid (\(key): \(rawDateValue))."
                )
                return nil
            }
            return .init(date.timeIntervalSince1970)
        default:
            return value
        }
    }

    func convert(
        rawContent: RawContent
    ) throws(ContentConverterError) -> Content {
        let typeId = rawContent.markdown.frontMatter.string("type")

        let contentType = try getContentType(
            for: rawContent.origin,
            using: typeId
        )

        var properties: [String: AnyCodable] = [:]

        // Convert schema-defined properties
        for (key, property) in contentType.properties.sorted(by: {
            $0.key < $1.key
        }) {

            let rawValue = rawContent.markdown.frontMatter[key]

            properties[key] = convert(
                property: property,
                rawValue: rawValue,
                forKey: key
            )
        }

        // Convert schema-defined relations
        var relations: [String: RelationValue] = [:]
        for (key, relation) in contentType.relations.sorted(by: {
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
            + contentType.properties.keys
            + contentType.relations.keys

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
        return .init(
            id: id,
            slug: .init(value: slug),
            rawValue: rawContent,
            definition: contentType,
            properties: properties,
            relations: relations,
            userDefined: userDefined,
            iteratorInfo: nil
        )
    }

    func getContentType(
        for origin: Origin,
        using id: String?
    ) throws(ContentConverterError) -> ContentDefinition {

        if let id {
            guard
                let result = contentTypes.first(where: { $0.id == id })
            else {
                //                logger.info("Explicit content type (\(explicitType)) not found")
                throw .missingContentType(id)
            }
            return result
        }

        if let type = contentTypes.first(
            where: { type in
                type.paths.contains { origin.path.hasPrefix($0) }
            }
        ) {
            return type
        }

        let results = contentTypes.filter { $0.default }
        precondition(
            !results.isEmpty,
            "Don't forget to validate build target first."
        )
        return results[0]
    }
}
