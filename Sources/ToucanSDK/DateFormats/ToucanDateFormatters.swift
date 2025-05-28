//
//  ToucanDateFormatters.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 05. 26..
//

import Foundation
import ToucanSource
import Logging

struct ToucanDateFormatter {

    var config: Config
    var pipeline: Pipeline
    var formatters: [String: DateFormatter]
    var logger: Logger

    init(
        config: Config,
        pipeline: Pipeline,
        logger: Logger
    ) {
        self.config = config
        self.pipeline = pipeline
        self.formatters = [:]
        self.logger = logger
    }

    private func createStandardFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = .init(identifier: "en-US")
        formatter.timeZone = .init(secondsFromGMT: 0)!
        return formatter
    }

    func parse(
        date: String,
        using: DateFormatterParameters?
    ) -> Date {
        .init()
    }

    func format(
        date: Date,
        using: DateFormatterParameters?
    ) -> DateFormats {
        .init(
            date: .init(
                full: "",
                long: "",
                medium: "",
                short: ""
            ),
            time: .init(
                full: "",
                long: "",
                medium: "",
                short: ""
            ),
            timestamp: 12,
            formats: [:]
        )
    }

    //    func config(with target: Target) {
    //        locale = .init(identifier: target.locale)
    //        if let value = TimeZone(identifier: target.timeZone) {
    //            timeZone = value
    //        }
    //    }
    //
    //    func dateFormatter(_ format: String? = nil) -> DateFormatter {
    //        let formatter = createStandardFormatter()
    //
    //        if let format {
    //            formatter.dateFormat = format
    //        }
    //        return formatter
    //    }
    //
    //    func config(with dateFormat: LocalizedDateFormat) {
    //        if let rawLocale = dateFormat.locale {
    //            locale = .init(identifier: rawLocale)
    //        }
    //        if let rawTimeZone = dateFormat.timeZone,
    //            let value = TimeZone(identifier: rawTimeZone)
    //        {
    //            timeZone = value
    //        }
    //        if let format = dateFormat.format.emptyToNil {
    //            self.dateFormat = format
    //        }
    //    }

    //    func prepareFormatters() -> [String: DateFormatter] {
    //        var formatters: [String: DateFormatter] = [:]
    //        let styles: [(String, DateFormatter.Style)] = [
    //            ("full", .full),
    //            ("long", .long),
    //            ("medium", .medium),
    //            ("short", .short),
    //        ]
    //
    //        for (key, style) in styles {
    //            let dateFormatter = target.dateFormatter()
    //            dateFormatter.dateStyle = style
    //            dateFormatter.timeStyle = .none
    //            formatters["date.\(key)"] = dateFormatter
    //
    //            let timeFormatter = target.dateFormatter()
    //            timeFormatter.dateStyle = .none
    //            timeFormatter.timeStyle = style
    //            formatters["time.\(key)"] = timeFormatter
    //        }
    //
    //        let standard: [String: LocalizedDateFormat] = [
    //            "iso8601": .init(format: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"),
    //            "rss": .init(format: "EEE, dd MMM yyyy HH:mm:ss Z"),
    //            "sitemap": .init(format: "yyyy-MM-dd"),
    //        ]
    //
    //        for (key, dateFormat) in standard.recursivelyMerged(
    //            with: config.dateFormats.output
    //        ) {
    //            let formatter = target.dateFormatter()
    //            formatter.config(with: dateFormat)
    //            formatters[key] = formatter
    //        }
    //        return formatters
    //    }

}
