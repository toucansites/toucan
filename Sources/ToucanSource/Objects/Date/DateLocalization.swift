//
//  DateLocalization.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 05. 28..
//

import struct Foundation.Locale
import struct Foundation.TimeZone

/// A set of locale and time zone identifiers used when formatting dates.
///
/// This type holds the locale and time zone identifiers that will be used
/// by a date formatter to localize its output.
public struct DateLocalization: Sendable, Codable, Equatable {
    // MARK: - Nested Types

    /// The keys used for encoding and decoding top-level date formatter properties.
    enum CodingKeys: CodingKey {
        case locale
        case timeZone
    }

    // MARK: - Static Computed Properties

    /// The default date localization options using the system’s default locale
    /// (`"en-US"`) and time zone (`"GMT"`).
    public static var defaults: Self {
        .init(
            locale: "en-US",
            timeZone: "GMT"
        )
    }

    // MARK: - Properties

    /// The locale identifier used for formatting (e.g., `"en_US"`, `"fr_FR"`).
    /// If `nil`, the system’s default locale will be used.
    public var locale: String

    /// The time zone identifier (e.g., `"UTC"`, `"Europe/Budapest"`).
    /// If `nil`, the system’s default time zone will be used.
    public var timeZone: String

    // MARK: - Lifecycle

    /// Creates a new date localization options instance.
    ///
    /// - Parameters:
    ///   - locale: A locale identifier (for example, `"en_US"` or `"fr_FR"`).
    ///   - timeZone: A time zone identifier (for example, `"UTC"` or `"Europe/Budapest"`).
    public init(
        locale: String,
        timeZone: String
    ) {
        self.locale = locale
        self.timeZone = timeZone
    }

    /// Creates a new instance by decoding from the given decoder.
    ///
    /// - Parameter decoder: The decoder to read data from.
    /// - Throws: An error if decoding fails, or if the locale or time zone identifier is invalid.
    public init(
        from decoder: any Decoder
    ) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let defaults = Self.defaults

        let locale =
            try container.decodeIfPresent(
                String.self,
                forKey: .locale
            ) ?? defaults.locale

        let timeZone =
            try container.decodeIfPresent(
                String.self,
                forKey: .timeZone
            ) ?? defaults.timeZone

        let id = Locale.identifier(.icu, from: locale)
        guard Locale.availableIdentifiers.contains(id) else {
            throw DecodingError.dataCorrupted(
                .init(
                    codingPath: container.codingPath,
                    debugDescription: "Invalid locale identifier."
                )
            )
        }

        guard TimeZone(identifier: timeZone) != nil else {
            throw DecodingError.dataCorrupted(
                .init(
                    codingPath: container.codingPath,
                    debugDescription: "Invalid time zone identifier."
                )
            )
        }

        self.locale = locale
        self.timeZone = timeZone
    }

    // MARK: - Functions

    /// Encodes this `DateFormatterOptions` into the given encoder.
    ///
    /// - Parameter encoder: The encoder to write data to.
    /// - Throws: An error if any values are invalid for the given encoder’s format.
    public func encode(
        to encoder: any Encoder
    ) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        let defaults = DateLocalization.defaults

        if locale != defaults.locale {
            try container.encode(locale, forKey: .locale)
        }
        if timeZone != defaults.timeZone {
            try container.encode(timeZone, forKey: .timeZone)
        }
    }
}
