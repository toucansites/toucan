//
//  DateFormatter+Locale.swift
//  Toucan
//
//  Created by Viasz-Kádi Ferenc on 2025. 03. 28..
//

import Foundation
import ToucanSource

extension DateFormatter {

    static var `default`: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = .init(identifier: "en-US")
        formatter.timeZone = .init(secondsFromGMT: 0)!
        return formatter
    }

    func config(with target: Target) {
        locale = .init(identifier: target.locale)
        if let value = TimeZone(identifier: target.timeZone) {
            timeZone = value
        }
    }

    func config(with dateFormat: DateFormatterParameters) {
        //        if let rawLocale = dateFormat.locale {
        //            locale = .init(identifier: rawLocale)
        //        }
        //        if let rawTimeZone = dateFormat.timeZone,
        //            let value = TimeZone(identifier: rawTimeZone)
        //        {
        //            timeZone = value
        //        }
        if let format = dateFormat.format.emptyToNil {
            self.dateFormat = format
        }
    }
}
