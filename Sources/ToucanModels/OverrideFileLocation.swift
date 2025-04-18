//
//  OverrideFileLocation.swift
//  Toucan
//
//  Created by Tibor Bodecs on 2025. 01. 31..
//

/// Represents the location of a file that may be optionally overridden by another path.
///
/// This is useful in systems where a default file can be replaced by a user-defined version,
/// such as in theme customization, configuration overrides, or content fallback logic.
public struct OverrideFileLocation: Equatable {

    /// The original/default file path.
    public let path: String

    /// An optional override path that takes precedence over the original path, if available.
    public let overridePath: String?

    /// Initializes a new `OverrideFileLocation` instance.
    ///
    /// - Parameters:
    ///   - path: The default file path.
    ///   - overridePath: An optional path that overrides the default, if set.
    public init(path: String, overridePath: String? = nil) {
        self.path = path
        self.overridePath = overridePath
    }
}
