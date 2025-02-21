//
//  File.swift
//  toucan
//
//  Created by Tibor Bodecs on 2025. 01. 31..
//

import Foundation
import ToucanModels

extension SourceBundle {

    public func run(query: Query) -> [Content] {
        let bundle = contentBundles.first {
            query.contentType == $0.definition.type
        }
        guard let bundle else {
            print("ERROR: no such content type: `\(query.contentType)`.")
            return []
        }
        return filter(contents: bundle.contents, using: query)
    }

    private func compare(
        _ valueA: AnyCodable,
        _ valueB: AnyCodable,
        ascending: Bool,
        isInclusive: Bool = false
    ) -> Bool {
        if let a = valueA.value(as: Int.self),
            let b = valueB.value(as: Int.self)
        {
            if isInclusive {
                return ascending ? a <= b : a >= b
            }
            return ascending ? a < b : a > b
        }

        if let a = valueA.value(as: Double.self),
            let b = valueB.value(as: Double.self)
        {
            if isInclusive {
                return ascending ? a <= b : a >= b
            }
            return ascending ? a < b : a > b
        }

        if let a = valueA.value(as: String.self),
            let b = valueB.value(as: String.self)
        {
            if isInclusive {
                return ascending ? a <= b : a >= b
            }
            return ascending ? a < b : a > b
        }

        return false
    }

    private func filter(
        contents: [Content],
        using query: Query
    ) -> [Content] {
        var filteredContents = contents.filter { element in
            evaluate(condition: query.filter, with: element.queryFields)
        }

        for order in query.orderBy.reversed() {
            filteredContents.sort {
                a,
                b in
                guard
                    let valueA = a.properties[order.key],
                    let valueB = b.properties[order.key]
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

    private func evaluate(
        condition: Condition?,
        with props: [String: AnyCodable]
    ) -> Bool {
        guard let condition else {
            return true
        }
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

    private func equals(
        _ valueA: AnyCodable,
        _ valueB: AnyCodable
    ) -> Bool {
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

    private func evaluateField(
        fieldValue: AnyCodable,
        operator: Operator,
        value: AnyCodable
    ) -> Bool {
        switch `operator` {
        case .equals:
            return equals(fieldValue, value)
        case .notEquals:
            return !equals(fieldValue, value)
        case .lessThan:
            return compare(fieldValue, value, ascending: true)
        case .greaterThan:
            return compare(fieldValue, value, ascending: false)
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
            guard
                let fieldString = fieldValue.value(as: String.self),
                let valueString = value.value(as: String.self)
            else {
                return false
            }
            return fieldString.contains(valueString)
        case .caseInsensitiveLike:
            guard
                let fieldString = fieldValue.value(as: String.self),
                let valueString = value.value(as: String.self)
            else {
                return false
            }
            return fieldString.lowercased().contains(valueString.lowercased())
        case .in:
            if let fieldValue = fieldValue.value(as: Int.self),
                let intArray = value.value(as: [Int].self)
            {
                return intArray.contains(fieldValue)
            }
            if let fieldValue = fieldValue.value(as: Double.self),
                let doubleArray = value.value(as: [Double].self)
            {
                return doubleArray.contains(fieldValue)
            }
            if let fieldValue = fieldValue.value(as: String.self),
                let stringArray = value.value(as: [String].self)
            {
                return stringArray.contains(fieldValue)
            }
            return false
        case .contains:

            if let fieldArray = fieldValue.value(as: [Int].self),
                let value = value.value(as: Int.self)
            {
                return fieldArray.contains(value)
            }
            if let fieldArray = fieldValue.value(as: [Double].self),
                let value = value.value(as: Double.self)
            {
                return fieldArray.contains(value)
            }
            if let fieldArray = fieldValue.value(as: [String].self),
                let value = value.value(as: String.self)
            {
                return fieldArray.contains(value)
            }
            return false
        case .matching:
            if let fieldArray = fieldValue.value(as: [Int].self),
                let valueArray = value.value(as: [Int].self)
            {
                return !Set(fieldArray).intersection(valueArray).isEmpty
            }
            if let fieldArray = fieldValue.value(as: [Double].self),
                let valueArray = value.value(as: [Double].self)
            {
                return !Set(fieldArray).intersection(valueArray).isEmpty
            }
            if let fieldArray = fieldValue.value(as: [String].self),
                let valueArray = value.value(as: [String].self)
            {
                return !Set(fieldArray).intersection(valueArray).isEmpty
            }
            return false
        }
    }

}
