//
//  FrontMatterParser.swift
//  Toucan
//
//  Created by Tibor Bodecs on 03/05/2024.
//

import ToucanModels
import ToucanSource
import Logging

struct FrontMatterParser {

    let decoder: ToucanDecoder

    /// The logger instance
    let logger: Logger

    init(decoder: ToucanDecoder, logger: Logger) {
        self.decoder = decoder
        self.logger = logger
    }

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

        return try decoder.decode(
            [String: AnyCodable].self,
            from: String(parts.first!).dataValue()
        )
    }
}
