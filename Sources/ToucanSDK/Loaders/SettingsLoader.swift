//
//  SettingsLoader.swift
//  Toucan
//
//  Created by Viasz-Kádi Ferenc on 2025. 03. 05..
//

import Foundation
import FileManagerKit
import Logging
import ToucanFileSystem
import ToucanModels
import ToucanSource
import ToucanSerialization

/// Loads and merges settings files from a given source directory into a unified `Settings` object.
public struct SettingsLoader {

    // MARK: - Properties

    /// The base URL where settings files are located.
    let url: URL

    /// Optional override for the `baseUrl` field in the final merged settings.
    let baseUrl: String?

    /// List of settings file paths (relative to `url`) to load and merge.
    let locations: [String]

    /// Encoder used to serialize intermediate raw merged YAML dictionaries.
    let encoder: ToucanEncoder

    /// Decoder used to load and parse individual and final settings values.
    let decoder: ToucanDecoder

    /// Logger for debug and error messages.
    let logger: Logger

    // MARK: - Public API

    /// Loads the settings from one or more configuration files.
    ///
    /// - This function:
    ///   - Loads and decodes each specified file as `[String: AnyCodable]`
    ///   - Merges all dictionaries into a single configuration map
    ///   - Optionally overrides the `"baseUrl"` key if provided
    ///   - Re-encodes the merged map and decodes it as a `Settings` object
    ///
    /// - Returns: A `Settings` object representing the final configuration.
    /// - Throws: An error if reading, decoding, or encoding fails.
    func load() throws -> Settings {
        logger.debug(
            "Loading settings files (\(locations)) at: `\(url.absoluteString)`"
        )

        var rawItems: [String] = []
        for location in locations {
            let item = try resolveItem(location)
            rawItems.append(item)
        }

        var combinedRawYaml =
            try rawItems
            .map { item in
                try decoder.decode(
                    [String: AnyCodable].self,
                    from: item.dataValue()
                )
            }
            .reduce([:]) { result, item in
                result.recursivelyMerged(with: item)
            }

        // Apply optional baseUrl override
        if let baseUrl {
            combinedRawYaml["baseUrl"] = .init(baseUrl)
        }

        let combinedYamlString = try encoder.encode(combinedRawYaml)
        return try decoder.decode(
            Settings.self,
            from: combinedYamlString.dataValue()
        )
    }
}

private extension SettingsLoader {

    /// Resolves a settings file relative to the base URL.
    ///
    /// - Parameter location: Relative file path.
    /// - Returns: The file's contents as a `String`.
    /// - Throws: If reading the file fails.
    func resolveItem(_ location: String) throws -> String {
        let fileURL = url.appendingPathComponent(location)
        return try loadItem(at: fileURL)
    }

    /// Loads a file's contents from a given URL.
    ///
    /// - Parameter url: The full file path.
    /// - Returns: The contents as a string.
    /// - Throws: If the file cannot be read.
    func loadItem(at url: URL) throws -> String {
        try url.loadContents()
    }
}
