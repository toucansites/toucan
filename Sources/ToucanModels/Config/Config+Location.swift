//
//  Config+Location.swift
//  Toucan
//
//  Created by Tibor Bodecs on 2025. 02. 21..
//

extension Config {

    /// Represents a named location within the file system.
    public struct Location: Codable, Equatable {

        /// The file system path for this location (e.g., `"assets"`, `"public/images"`).
        public var path: String

        // MARK: - Initialization

        /// Initializes a new `Location` with a given path.
        ///
        /// - Parameter path: A relative or absolute path in the project.
        public init(path: String) {
            self.path = path
        }
    }
}
