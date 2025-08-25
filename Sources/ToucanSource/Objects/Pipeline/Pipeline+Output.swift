//
//  Pipeline+Output.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 02. 16..
//

public extension Pipeline {
    /// Describes the output configuration for a content pipeline.
    struct Output: Codable {

        private enum CodingKeys: CodingKey, CaseIterable {
            case path
            case file
            case ext
        }

        /// The directory path where the output file should be written.
        ///
        /// This is relative to the site's output root (e.g., `"public/blog"`).
        public var path: String

        /// The base file name of the output file (without extension).
        ///
        /// Common values include `"index"`, `"feed"`, etc.
        public var file: String

        /// The file extension of the output file (e.g., `"html"`, `"json"`, `"xml"`).
        public var ext: String

        /// Initializes a new `Output` configuration.
        ///
        /// - Parameters:
        ///   - path: The relative path to the output directory.
        ///   - file: The base file name (e.g., `"index"`).
        ///   - ext: The file extension (e.g., `"html"`).
        public init(
            path: String,
            file: String,
            ext: String
        ) {
            self.path = path
            self.file = file
            self.ext = ext
        }

        /// Decodes the `Output` configuration from a serialized format (e.g., JSON/YAML).
        ///
        /// - Throws: A decoding error if any required key is missing.
        public init(
            from decoder: any Decoder
        ) throws {
            try decoder.validateUnknownKeys(keyType: CodingKeys.self)

            let container = try decoder.container(keyedBy: CodingKeys.self)

            let path = try container.decode(String.self, forKey: .path)
            let file = try container.decode(String.self, forKey: .file)
            let ext = try container.decode(String.self, forKey: .ext)

            self.init(
                path: path,
                file: file,
                ext: ext
            )
        }
    }
}
