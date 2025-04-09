//
//  ConfigLoader.swift
//  Toucan
//
//  Created by Tibor Bodecs on 27/06/2024.
//

import Foundation
import FileManagerKit
import Logging
import ToucanFileSystem
import ToucanModels
import ToucanSource

public struct ConfigLoader {

    /// The URL of the source files.
    let url: URL

    /// Config file paths
    let locations: [String]

    let encoder: ToucanEncoder
    let decoder: ToucanDecoder

    /// The logger instance
    let logger: Logger

    /// An enumeration representing possible errors that can occur while loading the configuration.
    public enum Error: Swift.Error {
        /// Indicates that a required configuration file is missing at the specified URL.
        case missing(URL)
    }

    /// Loads the configuration.
    ///
    /// This function attempts to load a configuration file from a specified URL, parses the file contents,
    /// and returns a `Config` object based on the file's data. If the file is missing or cannot be parsed,
    /// an appropriate error is thrown.
    ///
    /// - Returns: A `Config` object representing the loaded configuration.
    /// - Throws: An error if the configuration file is missing or if its contents cannot be decoded.
    func load() throws -> Config {
        logger.debug(
            "Loading config files (\(locations) at: `\(url.absoluteString)`"
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
