//
//  File.swift
//  toucan
//
//  Created by Tibor Bodecs on 2025. 02. 21..
//

import Foundation
import ToucanModels

extension Property {

    func convert(
        key: String,
        rawValue: AnyCodable?,
        using formatter: DateFormatter
    ) -> AnyCodable? {

        if self.required, rawValue == nil {
            print("ERROR - property is missing: \(key).")
        }

        let value = rawValue ?? self.default

        switch self.type {
        case let .date(format):
            guard let rawDateValue = value?.value(as: String.self) else {
                print(
                    "ERROR: property is not a string (\(key): \(value ?? "nil"))."
                )
                return nil
            }
            formatter.dateFormat = format
            guard let value = formatter.date(from: rawDateValue) else {
                print(
                    "ERROR: property is not a date (\(key): \(value ?? "nil"))."
                )
                return nil
            }
            return .init(value.timeIntervalSince1970)
        default:
            return value
        }
    }
}
