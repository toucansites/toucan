//
//  ObjectLoader.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 05. 16..
//

import Foundation
import Logging
import ToucanSerialization
import ToucanCore

/// A utility to load and decode objects from files using a specified set of encoders and decoders.
struct ObjectLoader {

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

    /// Initializes a new `ObjectLoader` instance.
    ///
    /// - Parameters:
    ///   - url: The base directory of the files.
    ///   - locations: A list of relative paths to the files.
    ///   - encoder: Encoder for serializing intermediate data.
    ///   - decoder: Decoder for parsing file contents into models.
    ///   - logger: Optional logger for debugging purposes.
    init(
        url: URL,
        locations: [String],
        encoder: ToucanEncoder,
        decoder: ToucanDecoder,
        logger: Logger = .subsystem("object-loader")
    ) {
        self.url = url
        self.locations = locations
        self.encoder = encoder
        self.decoder = decoder
        self.logger = logger
    }

    /// Loads and decodes each file separately into an array of the specified type.
    ///
    /// - Parameter value: The `Codable` type to decode each file into.
    /// - Returns: An array of decoded objects.
    /// - Throws: An `ObjectLoaderError` if reading or decoding any file fails.
    func load<T: Decodable>(
        _ value: T.Type
    ) throws(ObjectLoaderError) -> [T] {
        logger.debug(
            "Loading each \(type(of: value)) files (\(locations)) at: `\(url.absoluteString)`"
        )

        var lastUrl: URL?
        do {
            return
                try locations
                .map {
                    let fileUrl = url.appendingPathComponent($0)
                    lastUrl = fileUrl
                    return fileUrl
                }
                .map { try Data(contentsOf: $0) }
                .map { try decoder.decode(T.self, from: $0) }
        }
        catch {
            throw .init(
                url: lastUrl ?? url,
                error: error
            )
        }
    }

    /// Loads, merges, and decodes multiple files into a single instance of the specified type.
    ///
    /// - Parameter value: The `Codable` type to decode the combined YAML data into.
    /// - Returns: A decoded object of the specified type.
    /// - Throws: An `ObjectLoaderError` if reading, merging, or decoding fails.
    func load<T: Codable>(
        _ value: T.Type
    ) throws(ObjectLoaderError) -> T {
        logger.debug(
            "Loading and combining \(type(of: value)) files (\(locations)) at: `\(url.absoluteString)`"
        )

        var lastUrl: URL?
        do {
            let combinedRawCodableObject =
                try locations
                .map {
                    let fileUrl = url.appendingPathComponent($0)
                    lastUrl = fileUrl
                    return fileUrl
                }
                .map { try Data(contentsOf: $0) }
                .map { try decoder.decode([String: AnyCodable].self, from: $0) }
                .reduce([:]) { $0.recursivelyMerged(with: $1) }

            let data: Data = try encoder.encode(combinedRawCodableObject)
            return try decoder.decode(T.self, from: data)

        }
        catch {
            throw .init(
                url: lastUrl ?? url,
                error: error
            )
        }
    }
}
