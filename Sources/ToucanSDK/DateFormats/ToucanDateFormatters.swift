//
//  ToucanDateFormatters.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 05. 26..
//

import Foundation
import Logging
import ToucanCore
import ToucanSource

/// ```
/// target:
///     dev:
///        input: ./src
///        output: ./docs
///        config: ./src/config.dev.yml => auto lookup like this?
///    -> default looks up for config.yml
///
///     live:
///        config: ./src/config.live.yml
///
///    config.dev.yml:
///        url: http://localhost:3000/
///
///        # output date formats basis
///
///        date:
///           input:
///              # input date formats basis
///              locale: en-US
///              timezone: Americas/Los_Angeles
///              format: yyyy-MM-dd'T'HH:mm:ss.SSS'Z'
///           output:
///              locale: en-US
///              timezone: Americas/Los_Angeles
///           formats:
///              year:
///                 format: "y"
///                 locale: hu-HU
///                 timezone: Europe/Budapest
///
///     pipeline -> overrides config completely
///        date:
///            input:
///                locale: ???
///                timezone: ???
///                format: yyyy-MM-dd'T'HH:mm:ss.SSS'Z'
///            output:
///                locale: en-US
///                timezone: Americas/Los_Angeles
///            formats:
///               year:
///                 format: "y"
///                 locale: ???
///                 timezone: ???
///
///    # content type
///        post
///            publication:
///                type: date
///                config: # input
///                    format:
///                    locale:
///                    timeZone:
/// ```

/// Extension to configure `DateFormatter` with localization and config options.
private extension DateFormatter {
    /// Creates and configures a `DateFormatter`.
    ///
    /// - Parameters:
    ///   - localization: The locale and time zone settings to apply.
    ///   - block: A closure to further configure the formatter.
    /// - Returns: A fully configured `DateFormatter`.
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

    /// Applies the given localization (locale and time zone) to the formatter.
    ///
    /// - Parameter localization: The locale and time zone options.
    func use(localization: DateLocalization) {
        let id = Locale.identifier(.icu, from: localization.locale)
        locale = .init(identifier: id)
        timeZone = .init(identifier: localization.timeZone)
    }

    /// Applies a `DateFormatterConfig` (format, locale, time zone) to the formatter.
    ///
    /// - Parameter config: The date formatter configuration.
    func use(config: DateFormatterConfig) {
        use(localization: config.localization)
        dateFormat = config.format
    }
}

/// Holds system date and time style `DateFormatter` instances and an ISO8601 formatter.
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

/// Main utility for parsing and formatting dates based on project configuration.
///
/// Combines input parsing, system-style formatters, and user-defined formats.
public struct ToucanInputDateFormatter {

    private var dateConfig: Config.DataTypes.Date
    private var inputFormatter: DateFormatter
    private var ephemeralFormatter: DateFormatter

    var logger: Logger

    /// Initializes the date formatter utility.
    ///
    /// - Parameters:
    ///   - dateConfig: The base date configuration from the project.
    ///   - logger: A logger instance for diagnostics.
    public init(
        dateConfig: Config.DataTypes.Date,
        logger: Logger = .subsystem("input-date-formatter")
    ) {
        self.dateConfig = dateConfig
        self.inputFormatter = .build { $0.use(config: dateConfig.input) }
        self.ephemeralFormatter = .build { $0.use(config: dateConfig.input) }
        self.logger = logger
    }

    /// Parses a date string into a `Date` object.
    ///
    /// - Parameters:
    ///   - string: The string representation of the date.
    ///   - config: Optional `DateFormatterConfig` to override the input format.
    /// - Returns: A `Date` if parsing succeeds, otherwise `nil`.
    public func date(
        from string: String,
        using config: DateFormatterConfig? = nil
    ) -> Date? {
        if let config {
            ephemeralFormatter.use(config: config)

            return ephemeralFormatter.date(from: string)
        }
        return inputFormatter.date(from: string)
    }

    /// Converts a date into a `String` object.
    ///
    /// - Parameters:
    ///   - date: The date representation.
    ///   - config: Optional `DateFormatterConfig` to override the input format.
    /// - Returns: A `String` using the provided date format config.
    public func string(
        from date: Date,
        using config: DateFormatterConfig? = nil
    ) -> String {
        if let config {
            ephemeralFormatter.use(config: config)

            return ephemeralFormatter.string(from: date)
        }
        return inputFormatter.string(from: date)
    }
}

/// Main utility for parsing and formatting dates based on project configuration.
///
/// Combines input parsing, system-style formatters, and user-defined formats.
public struct ToucanOutputDateFormatter {

    private var dateConfig: Config.DataTypes.Date
    private var pipelineDateConfig: Pipeline.DataTypes.Date?
    private var systemFormatters: SystemDateFormatters
    private var userFormatters: [String: DateFormatter]

    var logger: Logger

    /// Initializes the date formatter utility.
    ///
    /// - Parameters:
    ///   - dateConfig: The base date configuration from the project.
    ///   - pipelineDateConfig: Optional overrides for date configuration.
    ///   - logger: A logger instance for diagnostics.
    public init(
        dateConfig: Config.DataTypes.Date,
        pipelineDateConfig: Pipeline.DataTypes.Date? = nil,
        logger: Logger = .subsystem("date-formatter")
    ) {
        self.dateConfig = dateConfig
        self.pipelineDateConfig = pipelineDateConfig

        var localization = dateConfig.output
        if let outputLocalization = pipelineDateConfig?.output {
            localization = outputLocalization
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
            (pipelineDateConfig?.formats ?? [:]),
            uniquingKeysWith: { _, new in new }
        )
        for (key, config) in userFormatterConfig {
            userFormatters[key] = .build(using: localization) {
                $0.use(config: config)
            }
        }
    }

    /// Formats a `Date` into a `DateContext`, providing multiple style outputs and custom formats.
    ///
    /// - Parameter date: The `Date` to format.
    /// - Returns: A `DateContext` containing formatted strings and timestamp.
    public func format(
        _ date: Date
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

    /// Formats a time interval since 1970 into a `DateContext`.
    ///
    /// - Parameter timestamp: The time interval (seconds since 1970).
    /// - Returns: A `DateContext` with formatted outputs.
    public func format(
        _ timestamp: TimeInterval
    ) -> DateContext {
        format(.init(timeIntervalSince1970: timestamp))
    }
}
