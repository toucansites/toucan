//
//  File.swift
//
//
//  Created by Tibor Bodecs on 07/05/2024.
//

import Foundation

struct DateFormatters {

    static var baseFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = .init(identifier: "en_US_POSIX")
        formatter.timeZone = .init(secondsFromGMT: 0)
        return formatter
    }

    static var contentLoader: DateFormatter {
        let formatter = baseFormatter
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }

    static var rss: DateFormatter {
        let formatter = baseFormatter
        formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z"
        return formatter
    }

    static var sitemap: DateFormatter {
        let formatter = baseFormatter
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }
}
