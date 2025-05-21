//
//  File.swift
//  toucan
//
//  Created by Tibor Bödecs on 2025. 05. 21..
//

import Foundation
import ToucanSource

extension BuildTargetSource {

    func prepareFormatters() -> [String: DateFormatter] {
        var formatters: [String: DateFormatter] = [:]
        let styles: [(String, DateFormatter.Style)] = [
            ("full", .full),
            ("long", .long),
            ("medium", .medium),
            ("short", .short),
        ]

        for (key, style) in styles {
            let dateFormatter = target.dateFormatter()
            dateFormatter.dateStyle = style
            dateFormatter.timeStyle = .none
            formatters["date.\(key)"] = dateFormatter

            let timeFormatter = target.dateFormatter()
            timeFormatter.dateStyle = .none
            timeFormatter.timeStyle = style
            formatters["time.\(key)"] = timeFormatter
        }

        let standard: [String: LocalizedDateFormat] = [
            "iso8601": .init(format: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"),
            "rss": .init(format: "EEE, dd MMM yyyy HH:mm:ss Z"),
            "sitemap": .init(format: "yyyy-MM-dd"),
        ]

        for (key, dateFormat) in standard.recursivelyMerged(
            with: config.dateFormats.output
        ) {
            let formatter = target.dateFormatter()
            formatter.config(with: dateFormat)
            formatters[key] = formatter
        }
        return formatters
    }
}
