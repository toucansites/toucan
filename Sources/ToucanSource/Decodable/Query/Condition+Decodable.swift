//
//  File.swift
//  toucan
//
//  Created by Tibor Bodecs on 2025. 01. 31..
//

import ToucanModels
import ToucanCodable

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
            let op = try? container.decode(Operator.self, forKey: .operator),
            let anyValue = try? container.decode(
                AnyCodable.self,
                forKey: .value
            )
        {
            self = .field(key: key, operator: op, value: anyValue)
        }
        else if let values = try? container.decode(
            [Condition].self,
            forKey: .and
        ) {
            self = .and(values)
        }
        else if let values = try? container.decode(
            [Condition].self,
            forKey: .or
        ) {
            self = .or(values)
        }
        else {
            throw DecodingError.dataCorrupted(
                .init(
                    codingPath: decoder.codingPath,
                    debugDescription: "Invalid data for the Condition type."
                )
            )
        }
    }
}
