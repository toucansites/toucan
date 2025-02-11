//
//  File.swift
//  ToucanV2
//
//  Created by Tibor Bodecs on 2025. 01. 21..
//

//import Foundation
//
//public indirect enum PropertyValue {
//    case bool(Bool)
//    case int(Int)
//    case double(Double)
//    case string(String)
//    case date(Double)
//    case array([PropertyValue])
//
//    public init?(_ value: Any) {
//        switch value {
//        case let boolValue as Bool:
//            self = .bool(boolValue)
//        case let intValue as Int:
//            self = .int(intValue)
//        case let doubleValue as Double:
//            self = .double(doubleValue)
//        case let dateValue as Date:
//            self = .date(dateValue.timeIntervalSince1970)
//        case let stringValue as String:
//            self = .string(stringValue)
//        case let arrayValue as [Any]:
//            // FIXME: log a warning if there was a value drop for the type.
//            self = .array(arrayValue.compactMap { PropertyValue($0) })
//        default:
//            return nil
//        }
//    }
//
//    public var value: Any {
//        switch self {
//        case .bool(let value):
//            return value
//        case .int(let value):
//            return value
//        case .double(let value):
//            return value
//        case .date(let value):
//            return value
//        case .string(let value):
//            return value
//        case .array(let values):
//            return values.map { $0.value }
//        }
//    }
//}
//
//extension PropertyValue: Hashable {
//
//}
//
//extension PropertyValue: Equatable {
//
//    public static func == (lhs: Self, rhs: Self) -> Bool {
//        switch (lhs, rhs) {
//        case let (.bool(lhsValue), .bool(rhsValue)):
//            return lhsValue == rhsValue
//        case let (.int(lhsValue), .int(rhsValue)):
//            return lhsValue == rhsValue
//        case let (.double(lhsValue), .double(rhsValue)):
//            return lhsValue == rhsValue
//        case let (.date(lhsValue), .date(rhsValue)):
//            return lhsValue == rhsValue
//        case let (.string(lhsValue), .string(rhsValue)):
//            return lhsValue == rhsValue
//        case let (.array(lhsValue), .array(rhsValue)):
//            return lhsValue == rhsValue
//        default:
//            return false
//        }
//    }
//}
//
//extension PropertyValue: Comparable {
//
//    // TODO: omg. this is getting ugly now.
//    public static func < (lhs: Self, rhs: Self) -> Bool {
//        switch (lhs, rhs) {
//        // FIXME: should we always return false in this case...? 🤔
//        case let (.bool(lhsValue), .bool(rhsValue)):
//            return !lhsValue && rhsValue
//        // int vs int
//        case let (.int(lhsValue), .int(rhsValue)):
//            return lhsValue < rhsValue
//        // int vs double
//        case let (.int(lhsValue), .double(rhsValue)):
//            return Double(lhsValue) < rhsValue
//        case let (.double(lhsValue), .int(rhsValue)):
//            return lhsValue < Double(rhsValue)
//        // double vs double
//        case let (.double(lhsValue), .double(rhsValue)):
//            return lhsValue < rhsValue
//        // string vs string
//        case let (.string(lhsValue), .string(rhsValue)):
//            return lhsValue < rhsValue
//        // date vs date
//        case let (.date(lhsValue), .date(rhsValue)):
//            return lhsValue < rhsValue
//        // date vs int
//        case let (.date(lhsValue), .int(rhsValue)):
//            return lhsValue < Double(rhsValue)
//        case let (.int(lhsValue), .date(rhsValue)):
//            return Double(lhsValue) < rhsValue
//        // date vs double
//        case let (.date(lhsValue), .double(rhsValue)):
//            return lhsValue < rhsValue
//        case let (.double(lhsValue), .date(rhsValue)):
//            return lhsValue < rhsValue
//
//        case (.array(_), .array(_)):
//            return false
//        default:
//            return order(lhs) < order(rhs)
//        }
//    }
//
//    private static func order(_ type: Self) -> Int {
//        switch type {
//        case .bool: return 0
//        case .int: return 1
//        case .double: return 2
//        case .date: return 3
//        case .string: return 4
//        case .array: return 5
//        }
//    }
//}
