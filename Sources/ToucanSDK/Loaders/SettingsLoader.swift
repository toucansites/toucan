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

public struct SettingsLoader {

    /// The URL of the source files.
    let url: URL

    let baseUrl: String?

    /// Settings file paths.
    let locations: [String]

    let encoder: ToucanEncoder

    let decoder: ToucanDecoder

    /// The logger instance
    let logger: Logger

    func load() throws -> Settings {
        logger.debug(
            "Loading settings files (\(locations) at: `\(url.absoluteString)`"
        )

        var rawItems: [String] = []
        for location in locations {
            let item = try resolveItem(location)
            rawItems.append(item)
        }

        var combinedRawYaml =
            try rawItems
            .map { i -> [String: AnyCodable] in
                try decoder.decode(
                    [String: AnyCodable].self,
                    from: i.dataValue()
                )
            }
            .reduce([:]) { partialResult, item -> [String: AnyCodable] in
                partialResult.recursivelyMerged(with: item)
            }

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
