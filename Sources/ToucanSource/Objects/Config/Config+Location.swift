//
//  Config+Location.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 02. 21..
//

public extension Config {
    /// Represents a named location within the file system.
    struct Location: Codable, Equatable {

        /// The file system path for this location (e.g., `"assets"`, `"public/images"`).
        public var path: String

        // MARK: - Lifecycle

        // MARK: - Initialization

        /// Initializes a new `Location` with a given path.
        ///
        /// - Parameter path: A relative or absolute path in the project.
        public init(path: String) {
            self.path = path
        }
    }
}
