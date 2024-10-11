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

    let sourceConfig: SourceConfig

    let fileLoader: FileLoader
    let yamlParser: YamlParser

    /// The logger instance
    let logger: Logger

    /// Loads and returns an array of content types.
    ///
    /// - Throws: An error if the content types could not be loaded.
    /// - Returns: An array of `ContentType` objects.
    func load() throws -> [ContentType] {
        // TODO: use theme override url to load additional / updated types
        let typesUrl = sourceConfig.currentThemeTypesUrl

        let contents = try fileLoader.findContents(at: typesUrl)

        logger.debug("Loading content types: `\(typesUrl.absoluteString)`.")

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
