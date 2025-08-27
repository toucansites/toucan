//
//  ObjectLoader.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 05. 16..
//

import Foundation
import Logging
import ToucanCore
import ToucanSerialization

/// A utility to load and decode objects from files using a specified set of encoders and decoders.
public struct ObjectLoader {

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
    public init(
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
    public func load<T: Decodable>(
        _ value: T.Type
    ) throws(ObjectLoaderError) -> [T] {
        logger.debug(
            "Loading each \(type(of: value)) files (\(locations)) at: `\(url.absoluteString)`"
        )

        var lastURL: URL?
        var result: [T] = []

        do {
            for location in locations {
                let fileURL = url.appendingPathIfPresent(location)
                lastURL = fileURL
                let data = try Data(contentsOf: fileURL)
                let decoded = try decoder.decode(T.self, from: data)

                result.append(decoded)
            }
        }
        catch {
            throw .init(
                url: lastURL ?? url,
                error: error
            )
        }

        return result
    }

    /// Loads, merges, and decodes multiple files into a single instance of the specified type.
    ///
    /// - Parameter value: The `Codable` type to decode the combined YAML data into.
    /// - Returns: A decoded object of the specified type.
    /// - Throws: An `ObjectLoaderError` if reading, merging, or decoding fails.
    public func load<T: Codable>(
        _ value: T.Type
    ) throws(ObjectLoaderError) -> T {
        logger.debug(
            "Loading and combining \(type(of: value)) files (\(locations)) at: `\(url.absoluteString)`"
        )

        var lastURL: URL?
        var combinedRawCodableObject: [String: AnyCodable] = [:]

        do {
            for location in locations {
                let fileURL = url.appendingPathIfPresent(location)
                lastURL = fileURL
                let data = try Data(contentsOf: fileURL)
                let decoded = try decoder.decode(
                    [String: AnyCodable].self,
                    from: data
                )

                combinedRawCodableObject =
                    combinedRawCodableObject.recursivelyMerged(with: decoded)
            }

            // TODO: Tries to decode 0 files too
            let data: Data = try encoder.encode(combinedRawCodableObject)
            return try decoder.decode(T.self, from: data)
        }
        catch {
            throw .init(
                url: lastURL ?? url,
                error: error
            )
        }
    }
}
