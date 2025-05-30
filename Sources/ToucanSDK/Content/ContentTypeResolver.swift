//
//  ContentTypeResolver.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 05. 30..
//

import ToucanSource
import ToucanCore

enum ContentTypeResolverError: ToucanError {

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

struct ContentTypeResolver {

    let contentTypes: [ContentDefinition]

    init(
        types: [ContentDefinition],
        pipelines: [Pipeline]
    ) {
        let virtualTypes = pipelines.compactMap {
            $0.definesType ? ContentDefinition(id: $0.id) : nil
        }

        self.contentTypes = (types + virtualTypes).sorted { $0.id < $1.id }
    }

    func getContentType(
        for origin: Origin,
        using id: String?
    ) throws(ContentTypeResolverError) -> ContentDefinition {

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
