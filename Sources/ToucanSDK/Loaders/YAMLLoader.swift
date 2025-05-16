//
//  YAMLLoader.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 05. 16..
//

import Foundation
import Logging
import ToucanModels
import ToucanSerialization

/// A utility for loading and decoding YAML files into Codable models.
///
/// `YAMLLoader` is designed to read and combine multiple YAML files from a specified directory,
/// decode their contents into a raw dictionary representation, merge them recursively, and finally
/// decode the result into a strongly typed Swift model.
public struct YAMLLoader {

    /// Internal errors that can be thrown by the loader.
    enum Error: Swift.Error {
        /// Indicates a failure to convert a YAML string into UTF-8 encoded data.
        case encoding
    }

    /// The base directory where the YAML files are located.
    let url: URL

    /// A list of relative paths (from `url`) to the YAML files to be loaded.
    let locations: [String]

    /// An encoder used for converting merged data structures back into YAML.
    let encoder: ToucanEncoder

    /// A decoder used for interpreting YAML data into Swift models.
    let decoder: ToucanDecoder

    /// Logger instance for emitting debug output during loading.
    let logger: Logger

    /// Loads and decodes YAML files into a specific `Codable` type.
    ///
    /// This method loads the YAML files specified in `locations`, combines their contents
    /// into a single dictionary via recursive merging, encodes the merged result back into
    /// a YAML string, and decodes that into an instance of the desired type.
    ///
    /// - Parameter value: The `Codable` type to decode the merged YAML data into.
    /// - Returns: An instance of the decoded type `T`.
    /// - Throws: An error if reading files fails, decoding fails, or if the final
    ///   YAML string cannot be encoded to UTF-8 data.
    func load<T: Codable>(
        _ value: T.Type
    ) throws -> T {
        logger.debug(
            "Loading \(type(of: value)) YAML files (\(locations)) at: `\(url.absoluteString)`"
        )

        let combinedRawCodableObject =
            try locations
            .map { url.appendingPathComponent($0) }
            //            .map { try Data(contentsOf: $0 }
            .map { try String(contentsOf: $0, encoding: .utf8) }
            .compactMap { $0.data(using: .utf8) }
            .map { try decoder.decode([String: AnyCodable].self, from: $0) }
            .reduce([:]) { $0.recursivelyMerged(with: $1) }

        let combinedYAMLString = try encoder.encode(combinedRawCodableObject)
        guard let data = combinedYAMLString.data(using: .utf8) else {
            throw Error.encoding
        }
        return try decoder.decode(T.self, from: data)
    }
}
