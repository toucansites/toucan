//
//  File.swift
//
//
//  Created by Tibor Bodecs on 27/06/2024.
//

import Foundation
import FileManagerKit
import Logging

public struct ConfigLoader {

    /// An enumeration representing possible errors that can occur while loading the configuration.
    public enum Error: Swift.Error {
        /// Indicates that a required configuration file is missing at the specified URL.
        case missing(URL)
    }

    /// The URL of the source files.
    let sourceUrl: URL
    /// A file loader used for loading files.
    let fileLoader: FileLoader
    /// The base URL to use for the configuration.
    let baseUrl: String?
    /// The logger instance
    let logger: Logger

    /// Loads the configuration.
    ///
    /// This function attempts to load a configuration file from a specified URL, parses the file contents,
    /// and returns a `Config` object based on the file's data. If the file is missing or cannot be parsed,
    /// an appropriate error is thrown.
    ///
    /// - Returns: A `Config` object representing the loaded configuration.
    /// - Throws: An error if the configuration file is missing or if its contents cannot be decoded.
    func load() throws -> Config {
        let configUrl = sourceUrl.appendingPathComponent("config")

        logger.debug("Loading config file: `\(configUrl.absoluteString)`.")

        do {
            let contents = try fileLoader.loadContents(at: configUrl)
            let yaml = try contents.decodeYaml()
            return .init(yaml)
        }
        catch FileLoader.Error.missing(let url) {
            throw Error.missing(url)
        }
    }
}
