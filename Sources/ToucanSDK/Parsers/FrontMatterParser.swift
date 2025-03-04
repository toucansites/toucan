//
//  File.swift
//
//
//  Created by Tibor Bodecs on 03/05/2024.
//

import ToucanModels

struct FrontMatterParser {

    let yamlParser: YamlParser

    /// Parses a given markdown string to extract metadata as a dictionary.
    /// - Parameter markdown: The markdown content containing metadata enclosed within "---".
    /// - Throws: An error if the YAML decoding fails.
    /// - Returns: A dictionary containing the parsed metadata if available, otherwise an empty dictionary.
    func parse(_ contents: String) throws -> [String: AnyCodable] {
        guard contents.starts(with: "---") else {
            return [:]
        }

        let parts = contents.split(
            separator: "---",
            maxSplits: 1,
            omittingEmptySubsequences: true
        )

        guard let rawMetadata = parts.first else {
            return [:]
        }

        return try yamlParser.decode(
            String(rawMetadata),
            as: [String: AnyCodable].self
        )
    }
}
