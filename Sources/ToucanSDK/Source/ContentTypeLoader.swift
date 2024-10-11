//
//  File.swift
//  toucan
//
//  Created by Tibor Bodecs on 19/07/2024.
//

import Foundation
import Logging

/// A struct responsible for loading and managing content types.
struct ContentTypeLoader {

    /// The URL of the source files.
    let sourceUrl: URL

    /// The configuration object that holds settings for the site.
    let config: Config

    let fileLoader: FileLoader
    let yamlParser: YamlParser

    /// The logger instance
    let logger: Logger

    /// Loads and returns an array of content types.
    ///
    /// - Throws: An error if the content types could not be loaded.
    /// - Returns: An array of `ContentType` objects.
    func load() throws -> [ContentType] {
        let typesUrl = sourceUrl.appendingPathComponent(config.types.folder)
        let contents = try fileLoader.findContents(at: typesUrl)

        logger.debug("Loading content type: `\(sourceUrl.absoluteString)`.")

        var types = try contents.map {
            try yamlParser.decode($0, as: ContentType.self)
        }

        // Adding the default content type if not present
        types.appendIfNot(.default) {
            $0.id == ContentType.default.id
        }

        // TODO: pagination type is not allowed
        types = types.filter { $0.id != ContentType.pagination.id }
        types.append(.pagination)

        return types
    }
}
