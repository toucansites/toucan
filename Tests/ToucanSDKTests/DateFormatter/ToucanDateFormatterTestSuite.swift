//
//  ToucanDateFormatterTestSuite.swift
//  Toucan
//
//  Created by Binary Birds on 2025. 04. 17..
//

import Foundation
import Logging
import Testing
@testable import ToucanSDK
import ToucanSource

@Suite
struct ToucanDateFormatterTestSuite {
    @Test
    func input() throws {
        let config = Config.defaults

        let dateFormatter = ToucanInputDateFormatter(
            dateConfig: config.dataTypes.date
        )

        let dateString = "2001-01-01T00:00:00.000Z"

        let inputDate = try #require(
            dateFormatter.date(from: dateString)
        )
        #expect(inputDate.timeIntervalSinceReferenceDate == 0)

        let localizedInputDate = try #require(
            dateFormatter.date(
                from: dateString,
                using: .init(
                    localization: .init(
                        locale: "hu-HU",
                        timeZone: "CET"
                    ),
                    format: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
                )
            )
        )
        #expect(localizedInputDate.timeIntervalSinceReferenceDate == -3600)
    }

    @Test
    func output() throws {
        let config = Config.defaults
        var pipeline = Mocks.Pipelines.html()
        pipeline.dataTypes.date.output = .init(
            locale: "hu-HU",
            timeZone: "CET"
        )

        let dateFormatter = ToucanOutputDateFormatter(
            dateConfig: config.dataTypes.date,
            pipelineDateConfig: pipeline.dataTypes.date
        )

        let date = Date(timeIntervalSinceReferenceDate: 0)
        let ctx = dateFormatter.format(date)

        #expect(ctx.date.full == "2001. január 1., hétfő")
        #expect(ctx.date.long == "2001. január 1.")
        #expect(ctx.date.medium == "2001. jan. 1.")
        #expect(ctx.date.short == "2001. 01. 01.")

        #expect(ctx.time.full == "1:00:00 közép-európai téli idő")
        #expect(ctx.time.long == "1:00:00 CET")
        #expect(ctx.time.medium == "1:00:00")
        #expect(ctx.time.short == "1:00")

        #expect(ctx.timestamp == 978_307_200)
        #expect(ctx.iso8601 == "2001-01-01T01:00:00.000Z")

        #expect(ctx.formats["rss"] == "Mon, 01 Jan 2001 00:00:00 +0000")
        #expect(ctx.formats["year"] == "2001")
        #expect(ctx.formats["sitemap"] == "2001-01-01")
    }
}
