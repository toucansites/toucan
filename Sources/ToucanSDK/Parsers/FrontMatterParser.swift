//
//  FrontMatterParser.swift
//  Toucan
//
//  Created by Tibor Bodecs on 2025. 04. 17..
//

import ToucanModels
import ToucanSource
import Logging

struct FrontMatterParser {

    let decoder: ToucanDecoder

    /// The logger instance
    let logger: Logger

    /// Parses a given markdown string to extract metadata as a dictionary.
    /// - Parameter contents: The markdown content containing metadata enclosed within "---".
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

        do {
            return try decoder.decode(
                [String: AnyCodable].self,
                from: String(parts.first!).dataValue()
            )
        }
        catch let error {
            logger.error("\(error.localizedDescription)")
        }

        return [:]
    }
}
