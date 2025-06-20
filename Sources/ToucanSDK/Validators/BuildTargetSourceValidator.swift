//
//  BuildTargetSourceValidator.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 05. 23..
//

import Foundation
import ToucanCore
import ToucanSerialization
import ToucanSource

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
        case let .unknown(error):
            [error]
        default:
            []
        }
    }

    var logMessage: String {
        switch self {
        case let .duplicateContentTypes(values):
            let items = values.map { "`\($0)`" }.joined(separator: ", ")
            return "Duplicate content types: \(items)."
        case .noDefaultContentType:
            return "No default content type."
        case let .multipleDefaultContentTypes(values):
            let items = values.map { "`\($0)`" }.joined(separator: ", ")
            return "Multiple default content types: \(items)."
        case let .duplicatePipelines(values):
            let items = values.map { "`\($0)`" }.joined(separator: ", ")
            return "Duplicate pipelines: \(items)."
        case let .duplicateRawContentSlugs(values):
            let items = values.map { "`\($0)`" }.joined(separator: ", ")
            return "Duplicate slugs: \(items)."
        case let .duplicateBlocks(values):
            let items = values.map { "`\($0)`" }.joined(separator: ", ")
            return "Duplicate blocks: \(items)."
        case let .invalidLocale(locale):
            return "Invalid site locale: `\(locale)`."
        case let .invalidTimeZone(timeZone):
            return "Invalid site time zone: `\(timeZone)`."
        case let .unknown(error):
            return error.localizedDescription
        }
    }

    var userFriendlyMessage: String {
        switch self {
        case let .duplicateContentTypes(values):
            let items = values.map { "`\($0)`" }.joined(separator: ", ")
            return "Duplicate content types: \(items)."
        case .noDefaultContentType:
            return "No default content type."
        case let .multipleDefaultContentTypes(values):
            let items = values.map { "`\($0)`" }.joined(separator: ", ")
            return "Multiple default content types: \(items)."
        case let .duplicatePipelines(values):
            let items = values.map { "`\($0)`" }.joined(separator: ", ")
            return "Duplicate pipelines: \(items)."
        case let .duplicateRawContentSlugs(values):
            let items = values.map { "`\($0)`" }.joined(separator: ", ")
            return "Duplicate slugs: \(items)."
        case let .duplicateBlocks(values):
            let items = values.map { "`\($0)`" }.joined(separator: ", ")
            return "Duplicate blocks: \(items)."
        case let .invalidLocale(locale):
            return "Invalid site locale: `\(locale)`."
        case let .invalidTimeZone(timeZone):
            return "Invalid site time zone: `\(timeZone)`."
        case .unknown:
            return "Unknown source validator error."
        }
    }
}

struct BuildTargetSourceValidator {

    var buildTargetSource: BuildTargetSource

    func validate() throws(BuildTargetSourceValidatorError) {
        try validatePipelines()
        try validateBlocks()
        try validateContentTypes()
        try validateRawContents()
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

    func validateBlocks() throws(BuildTargetSourceValidatorError) {
        let names = buildTargetSource.blocks.map(\.name)
        let duplicates = Dictionary(grouping: names, by: { $0 })
            .mapValues { $0.count }
            .filter { $1 > 1 }

        if !duplicates.isEmpty {
            throw .duplicateContentTypes(
                duplicates.keys.map { String($0) }.sorted()
            )
        }
    }

    func validateContentTypes() throws(BuildTargetSourceValidatorError) {
        let ids = buildTargetSource.types.map(\.id)
        let duplicates = Dictionary(grouping: ids, by: { $0 })
            .mapValues { $0.count }
            .filter { $1 > 1 }

        if !duplicates.isEmpty {
            throw .duplicateContentTypes(
                duplicates.keys.map { String($0) }.sorted()
            )
        }
        let items = buildTargetSource.types.filter(\.default)
        if items.isEmpty {
            throw .noDefaultContentType
        }
        if items.count > 1 {
            throw .multipleDefaultContentTypes(items.map(\.id).sorted())
        }
    }

    func validateRawContents() throws(BuildTargetSourceValidatorError) {
        let slugs = buildTargetSource.rawContents.map(\.origin.slug)
        let duplicates = Dictionary(grouping: slugs, by: { $0 })
            .mapValues { $0.count }
            .filter { $1 > 1 }

        if !duplicates.isEmpty {
            throw .duplicateRawContentSlugs(
                duplicates.keys.map { String($0) }.sorted()
            )
        }
    }
}
