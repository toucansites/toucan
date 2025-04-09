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

struct TemplateLoader {

    /// The URL of the source files.
    let url: URL

    let overridesUrl: URL

    /// Config file paths
    let locations: [TemplateLocation]

    /// The logger instance
    let logger: Logger

    /// An enumeration representing possible errors that can occur while loading the configuration.
    public enum Error: Swift.Error {
        /// Indicates that a required configuration file is missing at the specified URL.
        case missing(URL)
    }

    /// Loads and returns a map of templates
    ///
    /// - Throws: An error if the content types could not be loaded.
    /// - Returns: A map of `[String: String]` object.
    ///
    func load() throws -> [String: String] {
        var items: [String: String] = [:]
        for location in locations {
            let item = try resolveItem(location.path)
            items[location.id] = item
        }

        logger.debug(
            "Available templates: `\(items.map(\.key).joined(separator: ", "))`"
        )

        return items
    }

}

private extension TemplateLoader {

    func resolveItem(
        _ location: String
    ) throws -> String {
        let url = url.appendingPathComponent(location)
        return try loadItem(at: url)
    }

    func loadItem(at url: URL) throws -> String {
        try String(contentsOf: url, encoding: .utf8)
    }
}
