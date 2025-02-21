//
//  File.swift
//  ToucanV2
//
//  Created by Tibor Bodecs on 2025. 01. 21..
//

public enum Condition: Decodable {
    case field(key: String, operator: Operator, value: AnyCodable)
    case and([Condition])
    case or([Condition])

    private enum CodingKeys: CodingKey {
        case key
        case `operator`
        case value
        case and
        case or
    }

    // MARK: - decoder

    public init(
        from decoder: any Decoder
    ) throws {
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

extension Condition {

    public func resolve(with parameters: [String: AnyCodable]) -> Self {
        switch self {
        case .field(let key, let op, let value):
            guard
                let stringValue = value.value(as: String.self),
                stringValue.count > 4,
                stringValue.hasPrefix("{{"),
                stringValue.hasSuffix("}}")
            else {
                return self
            }
            let paramKeyToUse = String(stringValue.dropFirst(2).dropLast(2))
            guard let newValue = parameters[paramKeyToUse] else {
                return self
            }
            return .field(key: key, operator: op, value: newValue)
        case .and(let conditions):
            return .and(conditions.map { $0.resolve(with: parameters) })
        case .or(let conditions):
            return .or(conditions.map { $0.resolve(with: parameters) })
        }
    }
}
