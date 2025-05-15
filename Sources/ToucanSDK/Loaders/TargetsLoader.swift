//
//  TargetsLoader.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 05. 15..
//

import Foundation
import FileManagerKit
import Logging
import ToucanFileSystem
import ToucanModels
import ToucanSource
import ToucanSerialization

/// Load the targets files from a source directory.
public struct TargetsLoader {

    // MARK: - Properties

    /// The base URL where the target file is located.
    let url: URL

    /// The targets file name
    let fileName: String

    /// Decoder used for reading individual configuration files and the final merged config.
    let decoder: ToucanDecoder

    /// Logger instance for debug and error logging.
    let logger: Logger

    // MARK: - Error Types

    /// An enumeration representing possible errors that can occur while loading configuration.
    public enum Error: Swift.Error {
        /// Indicates that a required configuration file is missing at the specified path.
        case missing(URL)
    }

    // MARK: - Public API

    /// Loads and decodes the configuration from one or more config files.
    ///
    /// - Returns: A fully decoded `Targets` object.
    /// - Throws: `TargetsLoader.Error.missing` if any file is missing, or decoding errors.
    func load() throws -> Targets {
        logger.debug(
            "Loading target file at: `\(url.absoluteString)`"
        )

        let item = try url.appending(path: fileName).loadContents()
        let targets = try decoder.decode(Targets.self, from: item.dataValue())
        return targets
    }
}
