//
//  File.swift
//  toucan
//
//  Created by Tibor Bodecs on 19/07/2024.
//

import Foundation
import Logging
import ToucanFileSystem
import ToucanModels

/// A struct responsible for loading and managing content types.
struct ContentDefinitionLoader {

    let url: URL
    let overridesUrl: URL

    let locations: [OverrideFileLocation]

    let yamlParser: YamlParser
    let logger: Logger

    /// Loads and returns an array of content types.
    ///
    /// - Throws: An error if the content types could not be loaded.
    /// - Returns: An array of `ContentDefinition` objects.
    func load() throws -> [ContentDefinition] {
        var items: [ContentDefinition] = []
        for location in locations {
            let item = try resolveItem(location)

            if !items.contains(where: { $0.type == item.type }) {
                items.append(item)
            }
        }

        let typeList = items.map(\.type).joined(separator: ", ")
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
        let string = try String(contentsOf: url, encoding: .utf8)
        return try yamlParser.decode(string, as: ContentDefinition.self)
    }
}
