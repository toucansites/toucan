//
//  BuildTargetSourceValidator.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 05. 23..
//

import ToucanCore
import ToucanSource
import ToucanSerialization

enum BuildTargetSourceValidatorError: ToucanError {

    case duplicateContentTypes([String])
    case noDefaultContentType
    case multipleDefaultContentTypes([String])
    case duplicatePipelines([String])
    case duplicateRawContentSlugs([String])
    case duplicateBlocks([String])
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
        case .duplicateContentTypes(let values):
            let items = values.map { "`\($0)`" }.joined(separator: ", ")
            return "Duplicate content types: \(items)."
        case .noDefaultContentType:
            return "No default content type."
        case .multipleDefaultContentTypes(let values):
            let items = values.map { "`\($0)`" }.joined(separator: ", ")
            return "Multiple default content types: \(items)."
        case .duplicatePipelines(let values):
            let items = values.map { "`\($0)`" }.joined(separator: ", ")
            return "Duplicate pipelines: \(items)."
        case .duplicateRawContentSlugs(let values):
            let items = values.map { "`\($0)`" }.joined(separator: ", ")
            return "Duplicate slugs: \(items)."
        case .duplicateBlocks(let values):
            let items = values.map { "`\($0)`" }.joined(separator: ", ")
            return "Duplicate blocks: \(items)."
        case .unknown(let error):
            return error.localizedDescription
        }
    }

    var userFriendlyMessage: String {
        switch self {
        case .duplicateContentTypes(let values):
            let items = values.map { "`\($0)`" }.joined(separator: ", ")
            return "Duplicate content types: \(items)."
        case .noDefaultContentType:
            return "No default content type."
        case .multipleDefaultContentTypes(let values):
            let items = values.map { "`\($0)`" }.joined(separator: ", ")
            return "Multiple default content types: \(items)."
        case .duplicatePipelines(let values):
            let items = values.map { "`\($0)`" }.joined(separator: ", ")
            return "Duplicate pipelines: \(items)."
        case .duplicateRawContentSlugs(let values):
            let items = values.map { "`\($0)`" }.joined(separator: ", ")
            return "Duplicate slugs: \(items)."
        case .duplicateBlocks(let values):
            let items = values.map { "`\($0)`" }.joined(separator: ", ")
            return "Duplicate blocks: \(items)."
        case .unknown:
            return "Unknown source validator error."
        }
    }
}

struct BuildTargetSourceValidator {

    var buildTargetSource: BuildTargetSource

    func validate() throws(BuildTargetSourceValidatorError) {
        try validateContentTypes()
        try validatePipelines()
        try validateRawContents()
        try validateBlocks()

        //                validate(
        //                    .init(
        //                        locale: target.locale,
        //                        timeZone: target.timeZone,
        //                        format: ""
        //                    )
        //                )
        //
        //                /// Validate config date formats
        //                validate(sourceBundle.config.dateFormats.input)
        //                for dateFormat in sourceBundle.sourceConfig.config.dateFormats
        //                    .output.values
        //                {
        //                    validate(dateFormat)
        //                }
        //
        //                /// Validate pipeline date formats
        //                for pipeline in sourceBundle.pipelines {
        //                    for dateFormat in pipeline.dataTypes.date.dateFormats.values
        //                    {
        //                        validate(dateFormat)
        //                    }
        //                }
        //

        //                /// Validate frontMatters
        //                validateFrontMatters(sourceBundle)
    }

    // MARK: - validators

    //    func validate(_ dateFormat: LocalizedDateFormat) {
    //        if let value = dateFormat.locale {
    //            let canonicalId = Locale.identifier(.icu, from: value)
    //
    //            if !Locale.availableIdentifiers.contains(canonicalId) {
    //                logger.warning("Invalid site locale: \(value)")
    //            }
    //        }
    //        if let value = dateFormat.timeZone, TimeZone(identifier: value) == nil {
    //            logger.warning("Invalid site time zone: \(value)")
    //        }
    //    }
    //

    func validateContentTypes() throws(BuildTargetSourceValidatorError) {

        let ids = buildTargetSource.contentDefinitions.map(\.id)
        let duplicates = Dictionary(grouping: ids, by: { $0 })
            .mapValues { $0.count }
            .filter { $1 > 1 }

        if !duplicates.isEmpty {
            throw .duplicateContentTypes(
                duplicates.keys.map { String($0) }.sorted()
            )
        }

        let items = buildTargetSource.contentDefinitions.filter(\.default)
        if items.isEmpty {
            throw .noDefaultContentType
        }
        if items.count > 1 {
            throw .multipleDefaultContentTypes(items.map(\.id).sorted())
        }
    }

    func validatePipelines() throws(BuildTargetSourceValidatorError) {

        let ids = buildTargetSource.pipelines.map(\.id)
        let duplicates = Dictionary(grouping: ids, by: { $0 })
            .mapValues { $0.count }
            .filter { $1 > 1 }

        if !duplicates.isEmpty {
            throw .duplicateContentTypes(
                duplicates.keys.map { String($0) }.sorted()
            )
        }
    }

    func validateRawContents() throws(BuildTargetSourceValidatorError) {
        /// validate slugs
        let slugs = buildTargetSource.rawContents.map(\.origin.slug)
        let duplicates = Dictionary(grouping: slugs, by: { $0 })
            .mapValues { $0.count }
            .filter { $1 > 1 }

        if !duplicates.isEmpty {
            throw .duplicateRawContentSlugs(
                duplicates.keys.map { String($0) }.sorted()
            )
        }

        // validate front matters
    }

    //    func validateFrontMatters(_ sourceBundle: BuildTargetSource) {
    //        for content in sourceBundle.contents {
    //            let metadata: Logger.Metadata = ["slug": "\(content.slug.value)"]
    //            let frontMatter = content.rawValue.frontMatter
    //
    //            let missingProperties = content.definition.properties
    //                .filter { name, property in
    //                    property.required && frontMatter[name] == nil
    //                        && property.default?.value == nil
    //                }
    //
    //            for name in missingProperties.keys {
    //                logger.warning(
    //                    "Missing content property: `\(name)`",
    //                    metadata: metadata
    //                )
    //            }
    //
    //            let missingRelations = content.definition.relations.keys.filter {
    //                frontMatter[$0] == nil
    //            }
    //
    //            for name in missingRelations {
    //                logger.warning(
    //                    "Missing content relation: `\(name)`",
    //                    metadata: metadata
    //                )
    //            }
    //        }
    //    }

    func validateBlocks() throws(BuildTargetSourceValidatorError) {

        let names = buildTargetSource.blockDirectives.map(\.name)
        let duplicates = Dictionary(grouping: names, by: { $0 })
            .mapValues { $0.count }
            .filter { $1 > 1 }

        if !duplicates.isEmpty {
            throw .duplicateContentTypes(
                duplicates.keys.map { String($0) }.sorted()
            )
        }
    }
}
