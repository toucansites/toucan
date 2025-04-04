//
//  ContentDefinitionDetector.swift
//  Toucan
//
//  Created by Viasz-Kádi Ferenc on 2025. 03. 10..
//

import Foundation
import ToucanModels
import Logging

struct ContentDefinitionDetector {

    enum Failure: Error {
        case noExplicitContentDefinitionFound(String)
        case noDefaultContentDefinitionFound
        case multipleDefaultContentDefinitionsFound
    }

    let definitions: [ContentDefinition]
    let origin: Origin

    let logger: Logger

    func detect(explicitType: String?) throws -> ContentDefinition {
        /// Use explicit content definition if specified
        if let explicitType {
            guard let result = detectExplicitType(explicitType) else {
                logger.info("Explicit content type (\(explicitType)) not found")
                throw Failure.noExplicitContentDefinitionFound(explicitType)
            }
            return result
        }

        /// Searching in `paths` values
        if let matchingPathsType = detectMatchingPathsType() {
            return matchingPathsType
        }

        /// Find the default content definition if exists
        return try detectDefaultType()
    }
}

private extension ContentDefinitionDetector {

    func detectExplicitType(_ value: String) -> ContentDefinition? {
        definitions.first { $0.id == value }
    }

    func detectMatchingPathsType() -> ContentDefinition? {
        definitions.first { definition in
            definition.paths.contains { origin.path.hasPrefix($0) }
        }
    }

    func detectDefaultType() throws -> ContentDefinition {
        let results = definitions.filter { $0.default }

        guard !results.isEmpty else {
            logger.info("No content type found for slug: \(origin.slug)")
            throw Failure.noDefaultContentDefinitionFound
        }

        guard results.count == 1 else {
            let types = results.map { $0.id }.joined(separator: ", ")
            logger.info(
                "Multiple content types (\(types)) found for slug: `\(origin.slug)`"
            )
            throw Failure.multipleDefaultContentDefinitionsFound
        }

        return results[0]
    }
}
