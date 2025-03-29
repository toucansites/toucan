//
//  File.swift
//  toucan
//
//  Created by Viasz-Kádi Ferenc on 2025. 03. 28..
//

import Foundation
import ToucanModels

extension Double {

    func toDateFormats(
        formatters: [String: DateFormatter]
    ) -> DateFormats {
        let date = Date(timeIntervalSince1970: self)
        var results = formatters.mapValues { $0.string(from: date) }
        let dates = DateFormats.Standard(
            full: formatters["date-full"]!.string(from: date),
            long: formatters["date-long"]!.string(from: date),
            medium: formatters["date-medium"]!.string(from: date),
            short: formatters["date-short"]!.string(from: date)
        )
        let times = DateFormats.Standard(
            full: formatters["time-full"]!.string(from: date),
            long: formatters["time-long"]!.string(from: date),
            medium: formatters["time-medium"]!.string(from: date),
            short: formatters["time-short"]!.string(from: date)
        )
        
        results.removeValue(forKey: "date-full")
        results.removeValue(forKey: "date-long")
        results.removeValue(forKey: "date-medium")
        results.removeValue(forKey: "date-short")
        results.removeValue(forKey: "time-full")
        results.removeValue(forKey: "time-long")
        results.removeValue(forKey: "time-medium")
        results.removeValue(forKey: "time-short")
        
        return .init(
            date: dates,
            time: times,
            timestamp: self,
            formats: results
        )
    }
    
    func convertToDateFormats(
        formatter: DateFormatter,
        formats: [String: LocalizedDateFormat],
        settings: Settings
    ) -> DateFormats {
        let date = Date(timeIntervalSince1970: self)

        formatter.config(with: settings)
        
        let styles: [(String, DateFormatter.Style)] = [
            ("full", .full),
            ("long", .long),
            ("medium", .medium),
            ("short", .short),
        ]

        var dateFormats: [String: String] = [:]
        var timeFormats: [String: String] = [:]

        for (key, style) in styles {
            formatter.dateStyle = style
            formatter.timeStyle = .none
            dateFormats[key] = formatter.string(from: date)

            formatter.dateStyle = .none
            formatter.timeStyle = style
            timeFormats[key] = formatter.string(from: date)
        }

        let standard: [String: LocalizedDateFormat] = [
            "iso8601": .init(format: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"),
            "rss": .init(format: "EEE, dd MMM yyyy HH:mm:ss Z"),
            "sitemap": .init(format: "yyyy-MM-dd"),
        ]

        var custom: [String: String] = [:]
        for (key, dateFormat) in formats.recursivelyMerged(with: standard) {
            formatter.config(with: settings)
            formatter.config(with: dateFormat)
            custom[key] = formatter.string(from: date)
        }

        return .init(
            date: .init(
                full: dateFormats["full"]!,
                long: dateFormats["long"]!,
                medium: dateFormats["medium"]!,
                short: dateFormats["short"]!
            ),
            time: .init(
                full: timeFormats["full"]!,
                long: timeFormats["long"]!,
                medium: timeFormats["medium"]!,
                short: timeFormats["short"]!
            ),
            timestamp: self,
            formats: custom
        )
    }
}
