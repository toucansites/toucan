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

    /// The locale identifier used for formatting (e.g., `"en_US"`, `"fr_FR"`).
    /// If `nil`, the system’s default locale will be used.
    public var locale: String

    /// The time zone identifier (e.g., `"UTC"`, `"Europe/Budapest"`).
    /// If `nil`, the system’s default time zone will be used.
    public var timeZone: String

    /// The default date localization options using the system’s default locale
    /// (`"en-US"`) and time zone (`"GMT"`).
    public static var defaults: Self {
        .init(
            locale: "en-US",
            timeZone: "GMT"
        )
    }

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
        let locale = try container.decode(String.self, forKey: .locale)
        let timeZone = try container.decode(String.self, forKey: .timeZone)

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
}
