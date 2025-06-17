//
//  DateContext.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 02. 12..
//

/// A configuration container for date, time, and custom date-time formatting patterns.
///
/// `DateFormats` includes predefined formatting levels (full, long, medium, short)
/// for both dates and times, as well as support for arbitrary format labels.
public struct DateContext: Codable {
    /// Represents standardized formatting levels for a date or time value.
    ///
    /// These levels mirror common locale-aware date style options.
    public struct Standard: Codable {
        /// A fully verbose date format (e.g., `"EEEE, MMMM d, yyyy"`).
        public var full: String

        /// A long-form date format (e.g., `"MMMM d, yyyy"`).
        public var long: String

        /// A medium-form date format (e.g., `"MMM d, yyyy"`).
        public var medium: String

        /// A short-form date format (e.g., `"M/d/yy"`).
        public var short: String

        /// Initializes a new `Standard` date format set.
        ///
        /// - Parameters:
        ///   - full: Full verbose date format string.
        ///   - long: Long format string.
        ///   - medium: Medium format string.
        ///   - short: Short format string.
        public init(
            full: String,
            long: String,
            medium: String,
            short: String
        ) {
            self.full = full
            self.long = long
            self.medium = medium
            self.short = short
        }
    }

    /// Standardized date format strings (e.g., full, medium, short).
    public var date: Standard

    /// Standardized time format strings (e.g., full, medium, short).
    public var time: Standard

    /// A standard iso8601 date string.
    public var iso8601: String

    /// A Unix timestamp representing a default or reference point in time.
    public var timestamp: Double

    /// Additional named date format strings keyed by label.
    ///
    /// These can be used for custom formatting beyond the standard levels.
    public var formats: [String: String]

    /// Initializes a `DateFormats` configuration.
    ///
    /// - Parameters:
    ///   - date: Standardized date formatting options.
    ///   - time: Standardized time formatting options.
    ///   - timestamp: A base or reference timestamp, typically in Unix format.
    ///   - iso8601: A standard iso8601 date string.
    ///   - formats: Custom named format strings for specialized use cases.
    public init(
        date: Standard,
        time: Standard,
        timestamp: Double,
        iso8601: String,
        formats: [String: String]
    ) {
        self.date = date
        self.time = time
        self.timestamp = timestamp
        self.iso8601 = iso8601
        self.formats = formats
    }
}
