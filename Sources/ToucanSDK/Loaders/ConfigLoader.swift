//
//  ConfigLoader.swift
//  Toucan
//
//  Created by Tibor Bodecs on 2025. 04. 17..
//

import Foundation
import FileManagerKit
import Logging
import ToucanFileSystem
import ToucanModels
import ToucanSource
import ToucanSerialization

/// Loads and merges configuration files from a source directory.
public struct ConfigLoader {

    // MARK: - Properties

    /// The base URL where configuration files are located.
    let url: URL

    /// List of configuration file paths (relative to `url`) to load and merge.
    let locations: [String]

    /// Encoder used for serializing merged raw data (for round-tripping).
    let encoder: ToucanEncoder

    /// Decoder used for reading individual configuration files and the final merged config.
    let decoder: ToucanDecoder

    /// Logger instance for debug and error logging.
    let logger: Logger

    // MARK: - Error Types

    /// An enumeration representing possible errors that can occur while loading configuration.
    public enum Error: Swift.Error {
        /// Indicates that a required configuration file is missing at the specified path.
        case missing(URL)
    }

    // MARK: - Public API

    /// Loads and decodes the configuration from one or more config files.
    ///
    /// This process:
    /// - Reads each file path in `locations`
    /// - Decodes each file into `[String: AnyCodable]`
    /// - Merges all raw dictionaries (in order)
    /// - Encodes the merged dictionary back into a string
    /// - Decodes it into a typed `Config` object
    ///
    /// - Returns: A fully decoded `Config` object.
    /// - Throws: `ConfigLoader.Error.missing` if any file is missing, or decoding errors.
    func load() throws -> Config {
        logger.debug(
            "Loading config files (\(locations)) at: `\(url.absoluteString)`"
        )

        var rawItems: [String] = []
        for location in locations {
            let item = try resolveItem(location)
            rawItems.append(item)
        }

        let combinedRawYaml =
            try rawItems
            .compactMap {
                try decoder.decode(
                    [String: AnyCodable].self,
                    from: $0.dataValue()
                )
            }
            .reduce([:]) { partialResult, item in
                partialResult.recursivelyMerged(with: item)
            }

        let combinedYamlString = try encoder.encode(combinedRawYaml)
        return try decoder.decode(
            Config.self,
            from: combinedYamlString.dataValue()
        )
    }
}

private extension ConfigLoader {

    /// Resolves a single config item by appending the path to the base URL.
    ///
    /// - Parameter location: Relative path of the config file.
    /// - Returns: The file content as a raw string.
    /// - Throws: If loading the file fails.
    func resolveItem(_ location: String) throws -> String {
        let url = url.appendingPathComponent(location)
        return try loadItem(at: url)
    }

    /// Loads the content of a config file at the specified URL.
    ///
    /// - Parameter url: Absolute path to the file.
    /// - Returns: The content as a string.
    /// - Throws: If the file cannot be read.
    func loadItem(at url: URL) throws -> String {
        try url.loadContents()
    }
}
