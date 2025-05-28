//
//  ToucanDateFormatter.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 05. 26..
//

import Foundation
import ToucanSource
import Logging

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

    # content type
        post
            publication:
                type: date
                config: # input
                    format:
                    locale:
                    timeZone:

 */

fileprivate extension DateFormatter {

    static func build(
        using localization: DateLocalization = .defaults,
        _ block: (inout DateFormatter) -> Void
    ) -> DateFormatter {
        var formatter = DateFormatter()
        formatter.use(localization: localization)
        formatter.dateStyle = .none
        formatter.timeStyle = .none
        block(&formatter)
        return formatter
    }

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

private struct SystemDateFormatters {

    struct Date {
        var full: DateFormatter
        var long: DateFormatter
        var medium: DateFormatter
        var short: DateFormatter
    }

    struct Time {
        var full: DateFormatter
        var long: DateFormatter
        var medium: DateFormatter
        var short: DateFormatter
    }

    var date: Date
    var time: Time
    var iso8601: DateFormatter
}

struct ToucanDateFormatter {

    var dateConfig: Config.DataTypes.Date
    var pipelineDateConfig: Config.DataTypes.Date
    private var systemFormatters: SystemDateFormatters
    private var userFormatters: [String: DateFormatter]
    private var inputFormatter: DateFormatter
    private var ephemeralFormatter: DateFormatter

    var logger: Logger

    init(
        dateConfig: Config.DataTypes.Date,
        pipelineDateConfig: Config.DataTypes.Date,
        logger: Logger = .subsystem("toucan-date-formatter")
    ) {
        self.dateConfig = dateConfig
        self.pipelineDateConfig = pipelineDateConfig

        var localization = dateConfig.output
        if localization != pipelineDateConfig.output {
            localization = pipelineDateConfig.output
        }

        self.systemFormatters = .init(
            date: .init(
                full: .build(using: localization) { $0.dateStyle = .full },
                long: .build(using: localization) { $0.dateStyle = .long },
                medium: .build(using: localization) { $0.dateStyle = .medium },
                short: .build(using: localization) { $0.dateStyle = .short }
            ),
            time: .init(
                full: .build(using: localization) { $0.timeStyle = .full },
                long: .build(using: localization) { $0.timeStyle = .long },
                medium: .build(using: localization) { $0.timeStyle = .medium },
                short: .build(using: localization) { $0.timeStyle = .short }
            ),
            iso8601: .build(using: localization) {
                $0.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
            }
        )
        self.userFormatters = [:]
        self.logger = logger

        let userFormatterConfig = dateConfig.formats.merging(
            pipelineDateConfig.formats,
            uniquingKeysWith: { _, new in new }
        )
        for (key, config) in userFormatterConfig {
            userFormatters[key] = .build(using: localization) {
                $0.use(config: config)
            }
        }

        var config = dateConfig.input
        if config != pipelineDateConfig.input {
            config = pipelineDateConfig.input
        }

        self.inputFormatter = .build { $0.use(config: config) }
        self.ephemeralFormatter = .build { $0.use(config: config) }
    }

    // TODO: throw error
    func parse(
        date: String,
        using config: DateFormatterConfig? = nil
    ) -> Date {
        if let config {
            ephemeralFormatter.use(config: config)

            return ephemeralFormatter.date(from: date)!
        }
        return inputFormatter.date(from: date)!
    }

    func format(
        date: Date
    ) -> DateContext {
        .init(
            date: .init(
                full: systemFormatters.date.full.string(from: date),
                long: systemFormatters.date.long.string(from: date),
                medium: systemFormatters.date.medium.string(from: date),
                short: systemFormatters.date.short.string(from: date)
            ),
            time: .init(
                full: systemFormatters.time.full.string(from: date),
                long: systemFormatters.time.long.string(from: date),
                medium: systemFormatters.time.medium.string(from: date),
                short: systemFormatters.time.short.string(from: date)
            ),
            timestamp: date.timeIntervalSince1970,
            iso8601: systemFormatters.iso8601.string(from: date),
            formats: userFormatters.mapValues { $0.string(from: date) }
        )
    }

    func format(
        timestamp: TimeInterval
    ) -> DateContext {
        format(date: .init(timeIntervalSince1970: timestamp))
    }
}
