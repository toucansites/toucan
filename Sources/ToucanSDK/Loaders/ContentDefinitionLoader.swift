//
//  ContentDefinitionLoader.swift
//  Toucan
//
//  Created by Tibor Bodecs on 2025. 04. 09..
//

import Foundation
import ToucanFileSystem
import ToucanModels
import ToucanSource

/// A struct responsible for loading and managing content types.
struct ContentDefinitionLoader {

    let url: URL

    let locations: [String]

    let decoder: ToucanDecoder

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

        return items
    }
}

private extension ContentDefinitionLoader {

    func resolveItem(
        _ location: String
    ) throws -> ContentDefinition {
        let url = url.appendingPathComponent(location)
        return try loadItem(at: url)
    }

    func loadItem(at url: URL) throws -> ContentDefinition {
        let data = try Data(contentsOf: url)
        return try decoder.decode(ContentDefinition.self, from: data)
    }
}
