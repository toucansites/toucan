//
//  ContentTypeResolver.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 05. 30..
//

import ToucanCore
import ToucanSource

enum ContentTypeResolverError: ToucanError {
    case missingContentType(String)
    case unknown(Error)

    // MARK: - Computed Properties

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
        case .missingContentType:
            "Missing content type."
        case let .unknown(error):
            error.localizedDescription
        }
    }

    var userFriendlyMessage: String {
        switch self {
        case .missingContentType:
            "Missing content type."
        case .unknown:
            "Unknown content conversion error."
        }
    }
}

struct ContentTypeResolver {
    // MARK: - Properties

    let contentTypes: [ContentDefinition]

    // MARK: - Lifecycle

    init(
        types: [ContentDefinition],
        pipelines: [Pipeline]
    ) {
        let virtualTypes = pipelines.compactMap {
            $0.definesType ? ContentDefinition(id: $0.id) : nil
        }

        self.contentTypes = (types + virtualTypes).sorted { $0.id < $1.id }
    }

    // MARK: - Functions

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

        if
            let type = contentTypes.first(
                where: { type in
                    type.paths.contains { origin.path.value.hasPrefix($0) }
                }
            )
        {
            return type
        }

        let results = contentTypes.filter(\.default)
        precondition(
            !results.isEmpty,
            "Don't forget to validate build target first."
        )
        return results[0]
    }
}
