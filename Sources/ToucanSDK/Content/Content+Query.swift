//
//  Content+Query.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 01. 31..
//

import Foundation
import ToucanSource
import Logging

public extension Content {
    /// Flattens the content's core properties, relations, and metadata into a single dictionary
    /// for use in filtering, querying, or templating contexts.
    ///
    /// - Includes:
    ///   - All `properties` as defined in the content type
    ///   - Resolved `relations`, where:
    ///     - `.one` types return a single identifier (or an empty array if unresolved)
    ///     - `.many` types return an array of identifiers
    ///   - Additional metadata:
    ///     - `"id"`: The content's unique identifier
    ///     - `"slug"`: The slug string used for URLs
    ///     - `"lastUpdate"`: Last modification timestamp of the content
    ///     - `"iterator"`: Boolean flag indicating if this content is an iterator item
    ///
    /// - Returns: A `[String: AnyCodable]` dictionary representing queryable fields.
    var queryFields: [String: AnyCodable] {
        var fields = properties

        // Flatten relational fields by type
        for (key, relation) in relations {
            switch relation.type {
            case .one:
                if relation.identifiers.isEmpty {
                    // Default to empty array if no target
                    fields[key] = .init([])
                }
                else {
                    fields[key] = .init(relation.identifiers[0])  // Single ID
                }
            case .many:
                fields[key] = .init(relation.identifiers)  // Array of IDs
            }
        }

        // Append metadata fields
        fields[SystemPropertyKeys.id.rawValue] = .init(typeAwareID)
        fields[SystemPropertyKeys.lastUpdate.rawValue] = .init(
            rawValue.lastModificationDate
        )
        fields[SystemPropertyKeys.slug.rawValue] = .init(slug.value)
        fields[RootContextKeys.iterator.rawValue] = .init(isIterator)

        return fields
    }
}

public extension [Content] {
    /// Executes a `Query` against the current content collection, applying filtering,
    /// sorting, and pagination.
    ///
    /// - Parameters:
    ///   - query: The `Query` object containing filtering, ordering, and limit logic.
    ///   - now: The current timestamp used for time-based filtering.
    ///   - logger: A `Logger` instance for capturing logs.
    /// - Returns: A filtered, sorted, and paginated array of `Content` items.
    func run(
        query: Query,
        now: TimeInterval,
        logger: Logger
    ) -> [Content] {
        let contents = filter { query.contentType == $0.type.id }
        return filter(
            contents: contents,
            using: query.resolveFilterParameters(
                with: [
                    "date.now": .init(now)
                ]
            ),
            logger: logger
        )
    }

    /// Filters, sorts, and slices the given content array based on a query.
    private func filter(
        contents: [Content],
        using query: Query,
        logger: Logger
    ) -> [Content] {
        var filteredContents = contents.filter { element in
            evaluate(condition: query.filter, with: element.queryFields)
        }

        for order in query.orderBy.reversed() {
            filteredContents.sort { a, b in
                let propertyForOrderKey: (Content) -> AnyCodable? = { item in
                    guard let value = item.properties[order.key] else {
                        logger.warning(
                            "Missing order property key: `\(order.key)`.",
                            metadata: [
                                "slug": .string(item.slug.value),
                                "contentType": .string(query.contentType),
                            ]
                        )
                        return nil
                    }
                    return value
                }

                guard
                    let valueA = propertyForOrderKey(a),
                    let valueB = propertyForOrderKey(b)
                else {
                    return false
                }

                return compare(
                    valueA,
                    valueB,
                    ascending: order.direction == .asc
                )
            }
        }

        if let offset = query.offset {
            filteredContents = Array(filteredContents.dropFirst(offset))
        }

        if let limit = query.limit {
            filteredContents = Array(filteredContents.prefix(limit))
        }
        return filteredContents
    }

    /// Recursively evaluates a `Condition` tree against a set of content fields.
    private func evaluate(
        condition: Condition?,
        with props: [String: AnyCodable]
    ) -> Bool {
        guard let condition else { return true }

        switch condition {
        case let .field(key, `operator`, value):
            guard let fieldValue = props[key] else { return false }
            return evaluateField(
                fieldValue: fieldValue,
                operator: `operator`,
                value: value
            )

        case let .and(conditions):
            return conditions.allSatisfy {
                evaluate(condition: $0, with: props)
            }

        case let .or(conditions):
            return conditions.contains {
                evaluate(condition: $0, with: props)
            }
        }
    }

    /// Compares two values for equality, supporting multiple types.
    private func equals(_ valueA: AnyCodable, _ valueB: AnyCodable) -> Bool {
        if let a = valueA.value(as: Bool.self),
            let b = valueB.value(as: Bool.self)
        {
            return a == b
        }

        if let a = valueA.value(as: Int.self),
            let b = valueB.value(as: Int.self)
        {
            return a == b
        }

        if let a = valueA.value(as: Double.self),
            let b = valueB.value(as: Double.self)
        {
            return a == b
        }

        if let a = valueA.value(as: String.self),
            let b = valueB.value(as: String.self)
        {
            return a == b
        }

        return false
    }

    /// Performs numeric or string comparison between two values, with optional inclusiveness.
    private func compare(
        _ valueA: AnyCodable,
        _ valueB: AnyCodable,
        ascending: Bool,
        isInclusive: Bool = false
    ) -> Bool {
        if let a = valueA.value(as: Int.self),
            let b = valueB.value(as: Int.self)
        {
            return isInclusive
                ? (ascending ? a <= b : a >= b) : (ascending ? a < b : a > b)
        }

        if let a = valueA.value(as: Double.self),
            let b = valueB.value(as: Double.self)
        {
            return isInclusive
                ? (ascending ? a <= b : a >= b) : (ascending ? a < b : a > b)
        }

        if let a = valueA.value(as: String.self),
            let b = valueB.value(as: String.self)
        {
            return isInclusive
                ? (ascending ? a <= b : a >= b) : (ascending ? a < b : a > b)
        }

        return false
    }

    /// Evaluates a field condition against a value using the provided operator.
    private func evaluateField(
        fieldValue: AnyCodable,
        operator: Operator,
        value: AnyCodable
    ) -> Bool {
        switch `operator` {
        case .equals: return equals(fieldValue, value)

        case .notEquals: return !equals(fieldValue, value)

        case .lessThan: return compare(fieldValue, value, ascending: true)

        case .greaterThan: return compare(fieldValue, value, ascending: false)

        case .lessThanOrEquals:
            return compare(
                fieldValue,
                value,
                ascending: true,
                isInclusive: true
            )

        case .greaterThanOrEquals:
            return compare(
                fieldValue,
                value,
                ascending: false,
                isInclusive: true
            )

        case .like:
            return fieldValue.value(as: String.self)?
                .contains(value.value(as: String.self) ?? "") ?? false

        case .caseInsensitiveLike:
            return fieldValue.value(as: String.self)?
                .lowercased()
                .contains(value.value(as: String.self)?.lowercased() ?? "")
                ?? false

        case .in:
            if let v = fieldValue.value(as: Int.self),
                let arr = value.value(as: [Int].self)
            {
                return arr.contains(v)
            }
            if let v = fieldValue.value(as: Double.self),
                let arr = value.value(as: [Double].self)
            {
                return arr.contains(v)
            }
            if let v = fieldValue.value(as: String.self),
                let arr = value.value(as: [String].self)
            {
                return arr.contains(v)
            }
            return false

        case .contains:
            if let arr = fieldValue.value(as: [Int].self),
                let v = value.value(as: Int.self)
            {
                return arr.contains(v)
            }
            if let arr = fieldValue.value(as: [Double].self),
                let v = value.value(as: Double.self)
            {
                return arr.contains(v)
            }
            if let arr = fieldValue.value(as: [String].self),
                let v = value.value(as: String.self)
            {
                return arr.contains(v)
            }
            return false

        case .matching:
            if let arr = fieldValue.value(as: [Int].self),
                let other = value.value(as: [Int].self)
            {
                return !Set(arr).intersection(other).isEmpty
            }
            if let arr = fieldValue.value(as: [Double].self),
                let other = value.value(as: [Double].self)
            {
                return !Set(arr).intersection(other).isEmpty
            }
            if let arr = fieldValue.value(as: [String].self),
                let other = value.value(as: [String].self)
            {
                return !Set(arr).intersection(other).isEmpty
            }
            return false
        }
    }
}
