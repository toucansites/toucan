//
//  Decoder+Validate.swift
//  Toucan
//
//  Created by Ferenc Viasz-Kadi on 2025. 08. 19..
//

extension Decoder {

    /// Validates that the top-level decoded object contains no unknown keys outside the given `CodingKey` set.
    ///
    /// This method inspects the raw decoded object as a `[String: AnyCodable]` dictionary and compares its keys
    /// against the expected cases defined in the provided `CodingKey` type. If any extra keys are found that are
    /// not part of the enum, it throws a `DecodingError.dataCorruptedError`.
    ///
    /// - Parameter keyType: A `CodingKey` type that conforms to `CaseIterable`. This type defines the set of known/expected keys.
    /// - Throws: A `DecodingError.dataCorruptedError` if unexpected keys are found in the decoded object.
    public func validateUnknownKeys<K: CodingKey & CaseIterable>(
        keyType: K.Type
    ) throws {
        guard let _ = try? container(keyedBy: keyType) else {
            return
        }

        // Decode raw dictionary
        let raw = try singleValueContainer().decode([String: AnyCodable].self)

        let expectedKeys = Set(K.allCases.map { $0.stringValue })
        let actualKeys = Set(raw.keys)

        let unknownKeys = actualKeys.subtracting(expectedKeys)

        if !unknownKeys.isEmpty {
            let inputKeys =
                unknownKeys
                .sorted()
                .map { "`\($0)`" }
                .joined(separator: ", ")

            let expectedKeys =
                expectedKeys
                .sorted()
                .map { "`\($0)`" }
                .joined(separator: ", ")

            throw DecodingError.dataCorrupted(
                .init(
                    codingPath: codingPath,
                    debugDescription:
                        "Unknown keys found: \(inputKeys). Expected keys: \(expectedKeys)."
                )
            )
        }
    }
}
