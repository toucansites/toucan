//
//  Content+RunQuery.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 01. 31..
//

import Foundation

public extension [Content] {

    /// Executes a `Query` against the current content collection, applying filtering,
    /// sorting, and pagination.
    ///
    /// - Parameters:
    ///   - query: The `Query` object containing filtering, ordering, and limit logic.
    ///   - now: The current timestamp used for time-based filtering.
    /// - Returns: A filtered, sorted, and paginated array of `Content` items.
    func run(
        query: Query,
        now: TimeInterval
    ) -> [Content] {
        let contents = filter { query.contentType == $0.definition.id }
        return filter(
            contents: contents,
            using: query.resolveFilterParameters(
                with: [
                    "date.now": .init(now)
                ]
            )
        )
    }

    /// Filters, sorts, and slices the given content array based on a query.
    private func filter(
        contents: [Content],
        using query: Query
    ) -> [Content] {
        var filteredContents = contents.filter { element in
            evaluate(condition: query.filter, with: element.queryFields)
        }

        for order in query.orderBy.reversed() {
            filteredContents.sort { a, b in
                guard let valueA = a.properties[order.key],
                    let valueB = b.properties[order.key]
                else { return false }

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
        case .field(let key, let `operator`, let value):
            guard let fieldValue = props[key] else { return false }
            return evaluateField(
                fieldValue: fieldValue,
                operator: `operator`,
                value: value
            )

        case .and(let conditions):
            return conditions.allSatisfy {
                evaluate(condition: $0, with: props)
            }

        case .or(let conditions):
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
