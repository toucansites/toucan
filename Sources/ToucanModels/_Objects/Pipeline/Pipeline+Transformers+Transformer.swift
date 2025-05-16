//
//  Pipeline+Transformers+Transformer.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 05. 16..
//

import Foundation

extension Pipeline.Transformers {

    /// Represents a content transformer command used in a transformation pipeline.
    public struct Transformer: Codable {

        /// The directory path where the executable is located.
        /// Defaults to `"/usr/local/bin"` if not explicitly specified.
        public var path: String

        /// The name of the executable or script to run.
        public var name: String

        /// Initializes a new `ContentTransformer` with an optional path and required name.
        ///
        /// - Parameters:
        ///   - path: The directory path to the executable. Defaults to `"/usr/local/bin"`.
        ///   - name: The name of the command-line executable or script.
        public init(
            path: String = "/usr/local/bin",
            name: String
        ) {
            self.path = path
            self.name = name
        }

        /// Decodes a `ContentTransformer` from a decoder, falling back to default path if missing.
        ///
        /// - Throws: A decoding error if the required `name` is not present.
        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.path =
                (try? container.decode(String.self, forKey: .path))
                ?? "/usr/local/bin"
            self.name = try container.decode(String.self, forKey: .name)
        }

        /// Coding keys for decoding path and name properties.
        private enum CodingKeys: String, CodingKey {
            case path
            case name
        }
    }

}
