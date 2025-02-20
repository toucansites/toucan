//
//  File.swift
//  toucan
//
//  Created by Tibor Bodecs on 2025. 02. 19..
//

import Foundation

extension Dictionary {

    func mapKeys<Transformed>(
        _ transform: (Key) throws -> Transformed
    ) rethrows -> [Transformed: Value] {
        .init(
            uniqueKeysWithValues: try map { (try transform($0.key), $0.value) }
        )
    }
}

extension String {

    func replacingOccurrences(
        _ dictionary: [String: String]
    ) -> String {
        var result = self
        for (key, value) in dictionary {
            result = result.replacingOccurrences(of: key, with: value)
        }
        return result
    }

    func slugify() -> String {
        let allowed = CharacterSet(
            charactersIn: "abcdefghijklmnopqrstuvwxyz0123456789-_."
        )
        return trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
            .folding(
                options: .diacriticInsensitive,
                locale: .init(identifier: "en_US")
            )
            .components(separatedBy: allowed.inverted)
            .filter { $0 != "" }
            .joined(separator: "-")
    }
}
