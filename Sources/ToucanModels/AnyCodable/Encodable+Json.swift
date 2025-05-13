//
//  Encodable+Json.swift
//  Toucan
//
//  Created by Viasz-Kádi Ferenc on 2025. 05. 11..
//

import Foundation

public extension Encodable {

    /// Converts the current object to a JSON dictionary using the specified encoder.
    ///
    /// - Parameter encoder: The `JSONEncoder` used to encode the object.
    /// - Returns: A dictionary representation of the object if encoding and serialization succeed; otherwise, `nil`.
    func toJsonDictionary(_ encoder: JSONEncoder) -> [String: Any]? {
        do {
            let data = try encoder.encode(self)
            let json = try JSONSerialization.jsonObject(with: data, options: [])
            return json as? [String: Any]
        }
        catch {
            return nil
        }
    }
}
