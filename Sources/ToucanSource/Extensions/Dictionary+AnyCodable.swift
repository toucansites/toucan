//
//  Dictionary+AnyCodeable.swift
//  Toucan
//
//  Created by Tibor Bodecs on 2025. 01. 31..
//

import Foundation
import ToucanModels

extension Dictionary where Key == String, Value == AnyCodable {

    func value<T>(_ keyPath: String, as type: T.Type) -> T? {
        let keys = keyPath.split(separator: ".").map { String($0) }

        guard !keys.isEmpty else {
            return nil
        }
        var currentDict: [String: AnyCodable] = self

        for key in keys.dropLast() {
            if let dict = currentDict[key]?.value as? [String: AnyCodable] {
                currentDict = dict
            }
            else {
                return nil
            }
        }
        return currentDict[keys.last!]?.value as? T
    }

    func bool(_ keyPath: String) -> Bool? {
        value(keyPath, as: Bool.self)
    }

    func int(_ keyPath: String) -> Int? {
        value(keyPath, as: Int.self)
    }

    func double(_ keyPath: String) -> Double? {
        value(keyPath, as: Double.self)
    }

    func string(
        _ keyPath: String,
        allowingEmptyValue: Bool = false
    ) -> String? {
        let result = value(keyPath, as: String.self)
        if allowingEmptyValue {
            return result
        }
        return (result ?? "").isEmpty ? nil : result
    }

    func date(_ keyPath: String, formatter: DateFormatter) -> Date? {
        guard let rawDate = value(keyPath, as: String.self) else {
            return nil
        }
        return formatter.date(from: rawDate)
    }

    func array<T>(_ keyPath: String, as type: T.Type) -> [T] {
        value(keyPath, as: [T].self) ?? []
    }

    func dict(_ keyPath: String) -> [String: AnyCodable] {
        value(keyPath, as: [String: AnyCodable].self) ?? [:]
    }

}
