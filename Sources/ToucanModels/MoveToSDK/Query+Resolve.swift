//
//  Query+Resolve.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 05. 16..
//

extension Condition {

    /// Recursively resolves dynamic placeholders in the condition using a parameter map.
    ///
    /// Placeholders must be strings in the form `{{parameterKey}}` and will be
    /// replaced by values from the given parameters dictionary.
    ///
    /// - Parameter parameters: A dictionary of key-value pairs to substitute into the condition.
    /// - Returns: A new `Condition` with resolved values where applicable.
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

extension Query {

    /// Resolves dynamic filter parameters by injecting values into the filter condition tree.
    ///
    /// This is useful when filters include placeholders that need to be resolved at runtime.
    ///
    /// - Parameter parameters: A dictionary of key-value pairs to replace placeholders in the filter.
    /// - Returns: A new `Query` instance with resolved filter conditions.
    public func resolveFilterParameters(
        with parameters: [String: AnyCodable]
    ) -> Self {
        .init(
            contentType: contentType,
            scope: scope,
            limit: limit,
            offset: offset,
            filter: filter?.resolve(with: parameters),
            orderBy: orderBy
        )
    }
}
