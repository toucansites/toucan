//
//  ContentTypeResolver.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 05. 30..
//

import ToucanCore
import ToucanSource

enum ContentTypeResolverError: ToucanError {
    case missingContentType(String, String)
    case unknown(Error)

    var underlyingErrors: [any Error] {
        switch self {
        case .missingContentType:
            []
        case let .unknown(error):
            [error]
        }
    }

    var logMessage: String {
        switch self {
        case let .missingContentType(id, path):
            "Missing content type for identifier: `\(id)` at `\(path)`."
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

    let contentTypes: [ContentType]

    init(
        types: [ContentType],
        pipelines: [Pipeline]
    ) {
        let virtualTypes = pipelines.compactMap {
            $0.definesType ? ContentType(id: $0.id) : nil
        }

        self.contentTypes = (types + virtualTypes).sorted { $0.id < $1.id }
    }

    func getContentType(
        for origin: Origin,
        using id: String?
    ) throws(ContentTypeResolverError) -> ContentType {
        if let id {
            guard
                let result = contentTypes.first(where: { $0.id == id })
            else {
                throw .missingContentType(id, origin.path.value)
            }
            return result
        }

        if let type = contentTypes.first(
            where: { type in
                type.paths.contains { origin.path.value.hasPrefix($0) }
            }
        ) {
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
