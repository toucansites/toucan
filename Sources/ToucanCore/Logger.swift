//
//  Logger.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 05. 18..
//

import Logging

/// A protocol for types that can provide structured metadata for logging.
///
/// Conforming types expose a dictionary of metadata values used to enrich log messages.
public protocol LoggerMetadataRepresentable {
    /// A dictionary of key-value pairs representing structured logging metadata.
    ///
    /// This metadata can be used to provide additional context in log output.
    var logMetadata: [String: Logger.MetadataValue] { get }
}
