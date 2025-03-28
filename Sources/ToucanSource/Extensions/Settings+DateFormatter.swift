//
//  File.swift
//  toucan
//
//  Created by Viasz-Kádi Ferenc on 2025. 03. 26..
//

import Foundation
import ToucanModels

public extension Settings {

    func dateFormatter(_ format: String? = nil) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = .init(identifier: "en_US")
        formatter.timeZone = .init(secondsFromGMT: 0)

        if let rawLocale = locale {
            formatter.locale = .init(identifier: rawLocale)
        }
        if let rawTimezone = timeZone,
            let timeZone = TimeZone(identifier: rawTimezone)
        {
            formatter.timeZone = timeZone
        }
        if let format {
            formatter.dateFormat = format
        }
        return formatter
    }
}
