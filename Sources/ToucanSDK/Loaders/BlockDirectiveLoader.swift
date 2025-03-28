//
//  BlockDirectiveLoader.swift
//
//  Created by gerp83 on 2025. 03. 04.
//

import Foundation
import Logging
import ToucanModels
import ToucanContent
import ToucanFileSystem
import FileManagerKit
import ToucanSource

struct BlockDirectiveLoader {

    /// The URL of the source files.
    let url: URL

    let overridesUrl: URL

    /// Config file paths
    let locations: [OverrideFileLocation]

    /// A parser responsible for processing YAML data.
    let decoder: ToucanDecoder

    /// The logger instance
    let logger: Logger

    /// An enumeration representing possible errors that can occur while loading the configuration.
    public enum Error: Swift.Error {
        /// Indicates that a required configuration file is missing at the specified URL.
        case missing(URL)
    }

    /// Loads and returns an array of MarkdownBlockDirectives
    ///
    /// - Throws: An error if the content types could not be loaded.
    /// - Returns: An array of `MarkdownBlockDirective` objects.
    func load() throws -> [MarkdownBlockDirective] {
        var items: [MarkdownBlockDirective] = []
        for location in locations {
            let item = try resolveItem(location)
            items.append(item)
        }

        logger.debug(
            "Available block directives: `\(items.map(\.name).joined(separator: ", "))`."
        )

        return items
    }

}

private extension BlockDirectiveLoader {

    func resolveItem(
        _ location: OverrideFileLocation
    ) throws -> MarkdownBlockDirective {
        if let path = location.overridePath {
            let url = overridesUrl.appendingPathComponent(path)
            return try loadItem(at: url)
        }

        let url = url.appendingPathComponent(location.path)
        return try loadItem(at: url)
    }

    func loadItem(at url: URL) throws -> MarkdownBlockDirective {
        let data = try Data(contentsOf: url)
        return try decoder.decode(MarkdownBlockDirective.self, from: data)
    }
}
