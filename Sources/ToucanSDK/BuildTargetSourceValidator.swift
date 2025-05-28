//
//  BuildTargetSourceValidator.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 05. 23..
//

import Foundation
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
    case invalidLocale(String)
    case invalidTimeZone(String)
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
        case .invalidLocale(let locale):
            return "Invalid site locale: `\(locale)`."
        case .invalidTimeZone(let timeZone):
            return "Invalid site time zone: `\(timeZone)`."
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
        case .invalidLocale(let locale):
            return "Invalid site locale: `\(locale)`."
        case .invalidTimeZone(let timeZone):
            return "Invalid site time zone: `\(timeZone)`."
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

        /*
        
         target:
             dev:
                input: ./src
                output: ./docs
                config: ./src/config.dev.yml => auto lookup like this?
            -> default looks up for config.yml
        
             live:
                config: ./src/config.live.yml
        
            config.dev.yml:
                url: http://localhost:3000/
        
                # output date formats basis
        
                date:
                   input:
                      # input date formats basis
                      locale: en-US
                      timezone: Americas/Los_Angeles
                      format: yyyy-MM-dd'T'HH:mm:ss.SSS'Z'
                   output:
                      locale: en-US
                      timezone: Americas/Los_Angeles
                   formats:
                      year:
                         format: "y"
                         locale: hu-HU
                         timezone: Europe/Budapest
        
         pipeline -> overrides config completely
            date:
               input:
                    locale: ???
                    timezone: ???
                    format: yyyy-MM-dd'T'HH:mm:ss.SSS'Z'
                output:
                    locale: en-US
                    timezone: Americas/Los_Angeles
                formats:
                   year:
                     format: "y"
                     locale: ???
                     timezone: ???
        
        
        
         1 input formatter -> pipeline
         1 output formatter ->
        
        
        
         # content type
                post
                    publication:
                        date:
                          #custom input format...
                            format:
                            locale:
                            timeZone:
         */

        try validateLocalizations()

        /// Validate frontMatters
        //validateFrontMatters(sourceBundle)
    }

    // MARK: - validators

    func validateLocalizations() throws(BuildTargetSourceValidatorError) {
        try validate(
            .init(
                locale: buildTargetSource.target.locale,
                timeZone: buildTargetSource.target.timeZone,
            )
        )
        try validate(
            buildTargetSource.config.dateFormats.input.localization
        )
        for param in buildTargetSource.config.dateFormats.output.values {
            try validate(param.localization)
        }
        for pipeline in buildTargetSource.pipelines {
            for param in pipeline.dataTypes.date.dateFormats.values {
                try validate(param.localization)
            }

        }

        /// Validate frontMatters
        //validateFrontMatters(sourceBundle)
    }

    func validate(
        _ localization: DateLocalization
    ) throws(BuildTargetSourceValidatorError) {
        let id = Locale.identifier(
            .icu,
            from: localization.locale
        )

        guard Locale.availableIdentifiers.contains(id) else {
            throw .invalidLocale(localization.locale)
        }

        guard
            TimeZone(identifier: localization.timeZone)
                != nil
        else {
            throw .invalidTimeZone(localization.timeZone)
        }
    }

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
