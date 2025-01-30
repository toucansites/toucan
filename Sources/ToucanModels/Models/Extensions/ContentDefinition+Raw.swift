//
//  File.swift
//  toucan
//
//  Created by Tibor Bodecs on 2025. 01. 30..
//

import Foundation

extension Property {

    func convert(
        rawValue: Any?,
        using formatter: DateFormatter
    ) -> PropertyValue? {

        if self.required, rawValue == nil {
            print("ERROR: property is missing (\(key).")
        }

        let anyValue = rawValue ?? self.default

        var propertyValue: PropertyValue?
        switch self.type {
        case .bool:
            guard let value = anyValue as? Bool else {
                print(
                    "ERROR: property is not a bool (\(key): \(anyValue ?? "nil"))."
                )
                break
            }
            propertyValue = .bool(value)
        case .int:
            guard let value = anyValue as? Int else {
                print(
                    "ERROR: property is not an integer (\(key): \(anyValue ?? "nil"))."
                )
                break
            }
            propertyValue = .int(value)
        case .double:
            guard let value = anyValue as? Double else {
                print(
                    "ERROR: property is not a double (\(key): \(anyValue ?? "nil"))."
                )
                break
            }
            propertyValue = .double(value)
        case .string:
            guard let value = anyValue as? String else {
                print(
                    "ERROR: property is not a string (\(key): \(anyValue ?? "nil"))."
                )
                break
            }
            propertyValue = .string(value)
        case let .date(format):
            guard let rawDateValue = anyValue as? String else {
                print(
                    "ERROR: property is not a string (\(key): \(anyValue ?? "nil"))."
                )
                break
            }
            formatter.dateFormat = format
            guard let value = formatter.date(from: rawDateValue) else {
                print(
                    "ERROR: property is not a date (\(key): \(anyValue ?? "nil"))."
                )
                break
            }
            propertyValue = .date(value.timeIntervalSince1970)
        }
        return propertyValue
    }
}

extension ContentDefinition {

    public func convert(
        rawContent: RawContent,
        using formatter: DateFormatter
    ) -> Content {

        var properties: [String: PropertyValue] = [:]
        for property in self.properties {
            let rawValue = rawContent.frontMatter[property.key]
            let value = property.convert(rawValue: rawValue, using: formatter)
            properties[property.key] = value
        }

        return .init(
            rawValue: rawContent,
            properties: properties,
            relations: [:],
            userDefined: [:]
        )
    }
}
