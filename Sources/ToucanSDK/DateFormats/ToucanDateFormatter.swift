//
//  ToucanDateFormatter.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 05. 26..
//

import Foundation
import ToucanSource
import Logging

fileprivate extension DateFormatter {

    func use(localization: DateLocalization) {
        let id = Locale.identifier(.icu, from: localization.locale)
        locale = .init(identifier: id)
        timeZone = .init(identifier: localization.timeZone)
    }

    func use(config: DateFormatterConfig) {
        use(localization: config.localization)
        dateFormat = config.format
    }
}

/*

 target:
     dev:
        input: ./src
        output: ./docs
        config: ./src/config.dev.yml => auto lookup like this?
    -> default looks up for config.yml

     live:
        config: ./src/config.live.yml

    config.dev.yml:
        url: http://localhost:3000/

        # output date formats basis

        date:
           input:
              # input date formats basis
              locale: en-US
              timezone: Americas/Los_Angeles
              format: yyyy-MM-dd'T'HH:mm:ss.SSS'Z'
           output:
              locale: en-US
              timezone: Americas/Los_Angeles
           formats:
              year:
                 format: "y"
                 locale: hu-HU
                 timezone: Europe/Budapest

 pipeline -> overrides config completely
    date:
        input:
            locale: ???
            timezone: ???
            format: yyyy-MM-dd'T'HH:mm:ss.SSS'Z'
        output:
            locale: en-US
            timezone: Americas/Los_Angeles
        formats:
           year:
             format: "y"
             locale: ???
             timezone: ???



 1 input formatter -> pipeline
 1 output formatter ->



 # content type
        post
            publication:
                date:
                  #custom input format...
                    format:
                    locale:
                    timeZone:
 */

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

    private func createDefault() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.use(localization: .defaults)
        return formatter
    }

    func parse(
        date: String,
        using: DateFormatterConfig?
    ) -> Date {
        .init()
    }

    func format(
        date: Date,
        using: DateFormatterConfig?
    ) -> DateContext {
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

    //    func dateFormatter(_ format: String? = nil) -> DateFormatter {
    //        let formatter = createStandardFormatter()
    //
    //        if let format {
    //            formatter.dateFormat = format
    //        }
    //        return formatter
    //    }
    //

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

//extension Double {
//
//    func toDateFormats(
//        formatters: [String: DateFormatter]
//    ) -> DateContext {
//        let date = Date(timeIntervalSince1970: self)
//        var results = formatters.mapValues { $0.string(from: date) }
//        let dates = DateContext.Standard(
//            full: formatters["date.full"]!.string(from: date),
//            long: formatters["date.long"]!.string(from: date),
//            medium: formatters["date.medium"]!.string(from: date),
//            short: formatters["date.short"]!.string(from: date)
//        )
//        let times = DateContext.Standard(
//            full: formatters["time.full"]!.string(from: date),
//            long: formatters["time.long"]!.string(from: date),
//            medium: formatters["time.medium"]!.string(from: date),
//            short: formatters["time.short"]!.string(from: date)
//        )
//
//        results.removeValue(forKey: "date.full")
//        results.removeValue(forKey: "date.long")
//        results.removeValue(forKey: "date.medium")
//        results.removeValue(forKey: "date.short")
//        results.removeValue(forKey: "time.full")
//        results.removeValue(forKey: "time.long")
//        results.removeValue(forKey: "time.medium")
//        results.removeValue(forKey: "time.short")
//
//        return .init(
//            date: dates,
//            time: times,
//            timestamp: self,
//            formats: results
//        )
//    }
//}
