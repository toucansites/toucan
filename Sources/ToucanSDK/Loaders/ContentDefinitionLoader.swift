//
//  ContentDefinitionLoader.swift
//  Toucan
//
//  Created by Tibor Bodecs on 19/07/2024.
//

import Foundation
import Logging
import ToucanFileSystem
import ToucanModels
import ToucanSource

/// A struct responsible for loading and managing content types.
struct ContentDefinitionLoader {

    let url: URL
    let overridesUrl: URL

    let locations: [OverrideFileLocation]

    let decoder: ToucanDecoder
    let logger: Logger

    /// Loads and returns an array of content types.
    ///
    /// - Throws: An error if the content types could not be loaded.
    /// - Returns: An array of `ContentDefinition` objects.
    func load() throws -> [ContentDefinition] {
        var items: [ContentDefinition] = []
        for location in locations {
            let item = try resolveItem(location)

            if !items.contains(where: { $0.id == item.id }) {
                items.append(item)
            }
        }

        let typeList = items.map(\.id).joined(separator: ", ")
        logger.debug("Available content types: `\(typeList)`.")

        return items
    }
}

private extension ContentDefinitionLoader {

    func resolveItem(
        _ location: OverrideFileLocation
    ) throws -> ContentDefinition {
        if let path = location.overridePath {
            let url = overridesUrl.appendingPathComponent(path)
            return try loadItem(at: url)
        }

        let url = url.appendingPathComponent(location.path)
        return try loadItem(at: url)
    }

    func loadItem(at url: URL) throws -> ContentDefinition {
        let data = try Data(contentsOf: url)
        return try decoder.decode(ContentDefinition.self, from: data)
    }
}
