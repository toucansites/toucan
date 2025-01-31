//
//  File.swift
//  toucan
//
//  Created by Tibor Bodecs on 2025. 01. 31..
//

import ToucanModels

extension Condition: Decodable {

    private enum CodingKeys: CodingKey {
        case key
        case `operator`
        case value
        case and
        case or
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let key = try? container.decode(String.self, forKey: .key),
            let op = try? container.decode(Operator.self, forKey: .operator)
        {
            let value: Any

            if let intValue = try? container.decode(Int.self, forKey: .value) {
                value = intValue
            }
            else if let doubleValue = try? container.decode(
                Double.self,
                forKey: .value
            ) {
                value = doubleValue
            }
            else if let boolValue = try? container.decode(
                Bool.self,
                forKey: .value
            ) {
                value = boolValue
            }
            else if let stringValue = try? container.decode(
                String.self,
                forKey: .value
            ) {
                value = stringValue
            }
            // TODO: consider int, double, other type array support?
            else if let arrayValue = try? container.decode(
                [String].self,
                forKey: .value
            ) {
                value = arrayValue
            }
            else {
                throw DecodingError.dataCorruptedError(
                    forKey: .value,
                    in: container,
                    debugDescription: "Unsupported value type"
                )
            }

            self = .field(key: key, operator: op, value: value)
            return
        }

        if let values = try? container.decode([Condition].self, forKey: .and) {
            self = .and(values)
            return
        }

        if let values = try? container.decode([Condition].self, forKey: .or) {
            self = .or(values)
            return
        }

        throw DecodingError.dataCorrupted(
            .init(
                codingPath: [],
                debugDescription: "Invalid JSON structure for Condition"
            )
        )
    }
}
