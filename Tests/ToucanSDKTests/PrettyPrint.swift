//
//  PrettyPrint.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 02. 11..
//

import Foundation
import ToucanSource

/// Pretty prints a `[String: AnyCodable]` dictionary as JSON to standard output.
/// - Parameter object: A dictionary of key-value pairs with dynamic `AnyCodable` values.
public func prettyPrint(_ object: [String: AnyCodable]) {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [
        .prettyPrinted,
        .withoutEscapingSlashes,
        // .sortedKeys, // Enable if key ordering is desired
    ]

    do {
        let data = try encoder.encode(object)

        guard let dataString = String(data: data, encoding: .utf8) else {
            return
        }

        print(dataString)
    }
    catch {
        print("\(error)")
        fatalError(error.localizedDescription)
    }
}
