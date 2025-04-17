import Foundation
import Yams

/// An implementation of `ToucanDecoder` that uses `YAMLDecoder`.
public struct ToucanYAMLDecoder: ToucanDecoder {

    /// Creates a new YAML decoder instance for use in the Toucan system.
    public init() {}

    /// Decodes a YAML-formatted `Data` object into a strongly typed model.
    ///
    /// - Parameters:
    ///   - type: The expected `Decodable` type.
    ///   - data: The raw YAML data to decode.
    /// - Returns: A decoded instance of the specified type.
    /// - Throws: `ToucanDecoderError.decoding` if the input cannot be decoded.
    public func decode<T: Decodable>(
        _ type: T.Type,
        from data: Data
    ) throws(ToucanDecoderError) -> T {
        do {
            let decoder = YAMLDecoder()
            return try decoder.decode(type, from: data)
        }
        catch {
            throw .decoding(error, T.self)
        }
    }
}
