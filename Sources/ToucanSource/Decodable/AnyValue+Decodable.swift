//
//  File.swift
//  toucan
//
//  Created by Tibor Bodecs on 2025. 01. 31..
//

import Foundation

struct AnyValue: Decodable {

    let value: Any

    init(value: Any) {
        self.value = value
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let intValue = try? container.decode(Int.self) {
            self.value = intValue
        }
        else if let doubleValue = try? container.decode(Double.self) {
            self.value = doubleValue
        }
        else if let boolValue = try? container.decode(Bool.self) {
            self.value = boolValue
        }
        else if let stringValue = try? container.decode(String.self) {
            self.value = stringValue
        }
        // TODO: consider int, double, other type array support?
        else if let arrayValue = try? container.decode([AnyValue].self) {
            self.value = arrayValue.map { $0.value }
        }
        // TODO: consider other key types, int, etc?
        else if let dictValue = try? container.decode([String: AnyValue].self) {
            self.value = dictValue.mapValues { $0.value }
        }
        else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Unsupported data for the AnyValue type."
            )
        }
    }
}
