//
//  File.swift
//  toucan
//
//  Created by Tibor Bodecs on 2025. 01. 31..
//

import Foundation
import ToucanModels

extension AnyValue: Decodable {

    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let intValue = try? container.decode(Int.self) {
            self = .init(value: intValue)
        }
        else if let doubleValue = try? container.decode(Double.self) {
            self = .init(value: doubleValue)
        }
        else if let boolValue = try? container.decode(Bool.self) {
            self = .init(value: boolValue)
        }
        else if let stringValue = try? container.decode(String.self) {
            self = .init(value: stringValue)
        }
        // TODO: consider int, double, other type array support?
        else if let arrayValue = try? container.decode([AnyValue].self) {
            self = .init(value: arrayValue.map { $0.value })
        }
        // TODO: consider other key types, int, etc?
        else if let dictValue = try? container.decode([String: AnyValue].self) {
            self = .init(value: dictValue.mapValues { $0.value })
        }
        else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Unsupported data for the AnyValue type."
            )
        }
    }
}
