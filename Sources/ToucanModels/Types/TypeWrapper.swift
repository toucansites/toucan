//
//  File.swift
//  ToucanV2
//
//  Created by Tibor Bodecs on 2025. 01. 21..
//

import Foundation

public indirect enum TypeWrapper {
    case bool(Bool)
    case int(Int)
    case double(Double)
    case string(String)
    case date(Double)
    case array([TypeWrapper])

    public init?(_ value: Any) {
        switch value {
        case let boolValue as Bool:
            self = .bool(boolValue)
        case let intValue as Int:
            self = .int(intValue)
        case let doubleValue as Double:
            self = .double(doubleValue)
        case let stringValue as String:
            self = .string(stringValue)
        case let dateValue as Date:
            self = .date(dateValue.timeIntervalSince1970)
        case let arrayValue as [Any]:
            // FIXME: log a warning if there was a value drop for the type.
            self = .array(arrayValue.compactMap { TypeWrapper($0) })
        default:
            return nil
        }
    }
}

extension TypeWrapper: Equatable {

    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case let (.bool(lhsValue), .bool(rhsValue)):
            return lhsValue == rhsValue
        case let (.int(lhsValue), .int(rhsValue)):
            return lhsValue == rhsValue
        case let (.double(lhsValue), .double(rhsValue)):
            return lhsValue == rhsValue
        case let (.string(lhsValue), .string(rhsValue)):
            return lhsValue == rhsValue
        case let (.date(lhsValue), .date(rhsValue)):
            return lhsValue == rhsValue
        case let (.array(lhsValue), .array(rhsValue)):
            return lhsValue == rhsValue
        default:
            return false
        }
    }
}

extension TypeWrapper: Comparable {

    public static func < (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        // FIXME: should we always return false in this case...? 🤔
        case let (.bool(lhsValue), .bool(rhsValue)):
            return !lhsValue && rhsValue
        case let (.int(lhsValue), .int(rhsValue)):
            return lhsValue < rhsValue
        case let (.double(lhsValue), .double(rhsValue)):
            return lhsValue < rhsValue
        case let (.string(lhsValue), .string(rhsValue)):
            return lhsValue < rhsValue
        case let (.date(lhsValue), .date(rhsValue)):
            return lhsValue < rhsValue
        case (.array(_), .array(_)):
            return false
        default:
            return order(lhs) < order(rhs)
        }
    }

    private static func order(_ type: Self) -> Int {
        switch type {
        case .bool: return 0
        case .int: return 1
        case .double: return 2
        case .string: return 3
        case .date: return 4
        case .array: return 5
        }
    }
}
