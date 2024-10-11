//
//  File.swift
//  toucan
//
//  Created by Viasz-Kádi Ferenc on 2024. 10. 10..
//

import Foundation
import Yams

public struct YamlParser {

    /// An enumeration representing possible errors that can occur while parsing the yaml.
    public enum Error: Swift.Error {
        /// Indicates an error related to parsing YAML.
        case yaml(String)
    }

    /// A `Resolver` instance used during parsing.
    let resolver: Resolver

    /// Initializes a new instance with the specified resolver.
    /// - Parameter resolver: The resolver to use for the instance. Defaults to a resolver with the `.timestamp` case removed.
    init(resolver: Resolver = .default.removing(.timestamp)) {
        self.resolver = resolver
    }

    /// Parses a YAML string and attempts to convert it to a specified type.
    ///
    /// - Parameters:
    ///   - yaml: The YAML string to parse.
    ///   - as: The type to which the parsed YAML should be converted.
    /// - Returns: An optional value of the specified type if the parsing is successful, or `nil` if the conversion fails.
    /// - Throws: An `Error.yaml` if a `YamlError` occurs during parsing.
    func parse<T>(_ yaml: String, as: T.Type) throws -> T? {
        do {
            return try Yams.load(yaml: yaml, resolver) as? T
        }
        catch let error as YamlError {
            throw Error.yaml(error.description)
        }
    }

    /// Parses a YAML string and converts it into a dictionary.
    ///
    /// - Parameter yaml: A string containing YAML data.
    /// - Returns: A dictionary with string keys and values of any type, or nil if parsing fails.
    /// - Throws: An error if the YAML parsing fails.
    func parse(_ yaml: String) throws -> [String: Any]? {
        try parse(yaml, as: [String: Any].self)
    }

    /// Decodes a YAML string into a specified Decodable type.
    ///
    /// - Parameters:
    ///   - yaml: A `String` containing the YAML-formatted data to decode.
    ///   - as: The type of the Decodable object that the YAML data should be decoded into.
    /// - Returns: An instance of the specified type, decoded from the provided YAML string.
    /// - Throws: An error if the decoding process fails.
    func decode<T: Decodable>(_ yaml: String, as type: T.Type) throws -> T {
        try YAMLDecoder().decode(T.self, from: yaml)
    }
}
