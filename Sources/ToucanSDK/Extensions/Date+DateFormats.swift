//
//  Date+DateFormats.swift
//  Toucan
//
//  Created by Viasz-Kádi Ferenc on 2025. 03. 28..
//

import Foundation

extension Double {

    func toDateFormats(
        formatters: [String: DateFormatter]
    ) -> DateFormats {
        let date = Date(timeIntervalSince1970: self)
        var results = formatters.mapValues { $0.string(from: date) }
        let dates = DateFormats.Standard(
            full: formatters["date.full"]!.string(from: date),
            long: formatters["date.long"]!.string(from: date),
            medium: formatters["date.medium"]!.string(from: date),
            short: formatters["date.short"]!.string(from: date)
        )
        let times = DateFormats.Standard(
            full: formatters["time.full"]!.string(from: date),
            long: formatters["time.long"]!.string(from: date),
            medium: formatters["time.medium"]!.string(from: date),
            short: formatters["time.short"]!.string(from: date)
        )

        results.removeValue(forKey: "date.full")
        results.removeValue(forKey: "date.long")
        results.removeValue(forKey: "date.medium")
        results.removeValue(forKey: "date.short")
        results.removeValue(forKey: "time.full")
        results.removeValue(forKey: "time.long")
        results.removeValue(forKey: "time.medium")
        results.removeValue(forKey: "time.short")

        return .init(
            date: dates,
            time: times,
            timestamp: self,
            formats: results
        )
    }
}
