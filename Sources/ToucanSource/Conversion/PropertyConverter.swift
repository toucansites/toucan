//
//  PropertyConverter.swift
//  Toucan
//
//  Created by Tibor Bodecs on 2025. 02. 21..
//

import Foundation
import ToucanModels
import Logging

struct PropertyConverter {

    let property: Property
    let dateFormatter: DateFormatter
    let defaultDateFormat: LocalizedDateFormat

    let logger: Logger

    func convert(rawValue: AnyCodable?, forKey key: String) -> AnyCodable? {
        if property.required, rawValue == nil {
            logger.debug("ERROR - property is missing: \(key).")
        }

        let value = rawValue ?? property.default

        switch property.type {
        case .date(let dateFormat):
            guard let rawDateValue = value?.value(as: String.self) else {
                logger.debug(
                    "ERROR: property is not a string (\(key): \(value?.value ?? "nil"))."
                )
                return nil
            }

            if let dateFormat {
                dateFormatter.config(with: dateFormat)
            }

            guard let value = dateFormatter.date(from: rawDateValue) else {
                logger.debug(
                    "ERROR: property is not a date (\(key): \(value?.value ?? "nil"))."
                )
                return nil
            }
            return .init(value.timeIntervalSince1970)
        default:
            return value
        }
    }
}
