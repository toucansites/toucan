//
//  File.swift
//  ToucanV2
//
//  Created by Tibor Bodecs on 2025. 01. 21..
//

public enum Condition {
    case field(key: String, operator: Operator, value: AnyValue)
    case and([Condition])
    case or([Condition])
}

extension Condition {

    public func resolve(with parameters: [String: AnyValue]) -> Self {
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
