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

public struct ObjectLoaderError: ToucanError {

    let url: URL
    let error: Error?

    init(
        url: URL,
        error: Error? = nil
    ) {
        self.url = url
        self.error = error
    }

    public var underlyingErrors: [Error] {
        error.map { [$0] } ?? []
    }

    public var logMessage: String {
        "File issue at: `\(url.path())`."
    }

    public var userFriendlyMessage: String {
        "Could not load object."
    }
}

/// `ObjectLoader` is designed to load objects from files.
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

    /// Loads and decodes files into a specific `Codable` type.
    ///
    /// - Parameter value: The `Codable` type to decode the merged YAML data into.
    /// - Returns: An instance of the decoded type `T`.
    /// - Throws: An error if reading files fails, decoding fails.
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

    /// Loads and decodes files into a specific `Codable` type.
    ///
    /// - Parameter value: The `Codable` type to decode the merged YAML data into.
    /// - Returns: An instance of the decoded type `T`.
    /// - Throws: An error if reading files fails, decoding fails.
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
