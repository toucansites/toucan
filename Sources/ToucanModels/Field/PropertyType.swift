//
//  File.swift
//  ToucanV2
//
//  Created by Tibor Bodecs on 2025. 01. 21..
//

public enum PropertyType {
    case bool
    case int
    case double
    case string
    case date(format: String?)  // => fallback to global date format config
}

extension PropertyType: Equatable {

    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.bool, .bool), (.int, .int), (.double, .double),
            (.string, .string):
            return true
        case let (.date(format1), .date(format2)):
            return format1 == format2
        default:
            return false
        }
    }
}
