//
//  File.swift
//  toucan
//
//  Created by Viasz-Kádi Ferenc on 2024. 10. 10..
//

import Foundation

extension String {

    /// Decodes the current instance from a YAML string into a specified type.
    ///
    /// - Parameter as: The type to decode the YAML string into.
    /// - Returns: An optional instance of the specified type, decoded from the YAML string.
    /// - Throws: An error if the YAML parsing fails.
    func decodeYaml<T>(as: T.Type) throws -> T? {
        try YamlParser().parse(self, as: T.self)
    }

    /// Decodes a YAML string into a dictionary representation.
    ///
    /// - Returns: A dictionary with string keys and values of any type, representing the parsed YAML content.
    ///            Returns `nil` if the parsing fails.
    /// - Throws: An error if the YAML parsing fails.
    func decodeYaml() throws -> [String: Any]? {
        try YamlParser().parse(self)
    }
}

extension [String] {

    /// Decodes an array of YAML-encoded data into a single merged dictionary.
    ///
    /// - Returns: A dictionary of type `[String: Any]` representing the merged result of decoded YAML data.
    /// - Throws: An error if any of the decoding operations fail.
    func decodeYaml() throws -> [String: Any] {
        try self
            .compactMap {
                try $0.decodeYaml()
            }
            .reduce([:]) { partialResult, item in
                partialResult.recursivelyMerged(with: item)
            }
    }
}
