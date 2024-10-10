//
//  File.swift
//  toucan
//
//  Created by Tibor Bodecs on 19/07/2024.
//

import Foundation
import FileManagerKit
import Yams

/// A struct responsible for loading and managing content types.
struct ContentTypeLoader {

    /// An enumeration representing possible errors that can occur while loading the configuration.
    enum Error: Swift.Error {
        case missing
        /// Indicates an error related to file operations.
        case file(Swift.Error)
        /// Indicates an error related to parsing YAML.
        case yaml(YamlError)
    }

    /// The URL of the source files.
    let sourceUrl: URL

    /// The configuration object that holds settings for the site.
    let config: Config

    /// The file manager used for file operations.
    let fileManager: FileManager

    /// Loads and returns an array of content types.
    ///
    /// - Throws: An error if the content types could not be loaded.
    /// - Returns: An array of `ContentType` objects.
    func load() throws -> [ContentType] {
        // TODO: use theme override url to load additional / updated types
        // TODO: use yaml loader
        let typesUrl =
            sourceUrl
            .appendingPathComponent(config.themes.folder)
            .appendingPathComponent(config.themes.use)
            .appendingPathComponent(config.themes.types.folder)

        let list = fileManager.listDirectory(at: typesUrl)
            .filter { $0.hasSuffix(".yml") || $0.hasSuffix(".yaml") }

        var types: [ContentType] = []
        var useDefaultContentType = true
        for file in list {
            let decoder = YAMLDecoder()
            let data = try Data(
                contentsOf: typesUrl.appendingPathComponent(file)
            )
            let type = try decoder.decode(ContentType.self, from: data)
            types.append(type)
            if type.id == ContentType.default.id {
                useDefaultContentType = false
            }
        }
        if useDefaultContentType {
            types.append(.default)
        }
        // TODO: pagination type is not allowed
        types = types.filter { $0.id != ContentType.pagination.id }
        types.append(.pagination)

        return types
    }
}
