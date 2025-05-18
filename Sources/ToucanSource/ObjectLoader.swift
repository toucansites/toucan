//
//  ObjectLoader.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 05. 16..
//

import Foundation
import Logging

import ToucanSerialization

/// `ObjectLoader` is designed to load objects from files.
struct ObjectLoader {

    /// Internal errors that can be thrown by the loader.
    enum Error: Swift.Error {
        /// Indicates a failure to convert a string into UTF-8 encoded data.
        case encoding
    }

    /// The base directory where the files are located.
    let url: URL

    /// A list of relative paths (from `url`) to the files to be loaded.
    let locations: [String]

    /// An encoder used for interpreting Swift models into data.
    let encoder: ToucanEncoder

    /// A decoder used for interpreting data into Swift models.
    let decoder: ToucanDecoder

    /// Logger instance for emitting debug output during loading.
    let logger: Logger

    /// Loads and decodes files into a specific `Codable` type.
    ///
    /// - Parameter value: The `Codable` type to decode the merged YAML data into.
    /// - Returns: An instance of the decoded type `T`.
    /// - Throws: An error if reading files fails, decoding fails.
    func load<T: Decodable>(
        _ value: T.Type
    ) throws -> [T] {
        logger.debug(
            "Loading each \(type(of: value)) files (\(locations)) at: `\(url.absoluteString)`"
        )

        return
            try locations
            .map { url.appendingPathComponent($0) }
            .map { try Data(contentsOf: $0) }
            .map { try decoder.decode(T.self, from: $0) }
    }

    /// Loads and decodes files into a specific `Codable` type.
    ///
    /// - Parameter value: The `Codable` type to decode the merged YAML data into.
    /// - Returns: An instance of the decoded type `T`.
    /// - Throws: An error if reading files fails, decoding fails.
    func load<T: Codable>(
        _ value: T.Type
    ) throws -> T {
        logger.debug(
            "Loading and combining \(type(of: value)) files (\(locations)) at: `\(url.absoluteString)`"
        )

        let combinedRawCodableObject =
            try locations
            .map { url.appendingPathComponent($0) }
            .map { try Data(contentsOf: $0) }
            .map { try decoder.decode([String: AnyCodable].self, from: $0) }
            .reduce([:]) { $0.recursivelyMerged(with: $1) }

        let data: Data = try encoder.encode(combinedRawCodableObject)
        return try decoder.decode(T.self, from: data)
    }

}
