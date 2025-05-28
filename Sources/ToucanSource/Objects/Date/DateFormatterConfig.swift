//
//  DateFormatterConfig.swift
//  Toucan
//
//  Created by Viasz-Kádi Ferenc on 2025. 03. 28..
//

/// A configuration for formatting dates.
///
/// This type holds both localization options and a format string, allowing
/// dates to be formatted according to locale, time zone, and pattern.
public struct DateFormatterConfig: Sendable, Codable, Equatable {

    /// The locale and time zone options to apply when formatting dates.
    public var localization: DateLocalization

    /// The date format string (e.g., `"yyyy-MM-dd"`, `"MMMM d, yyyy"`).
    public var format: String

    /// Creates a new date formatter options instance.
    ///
    /// - Parameters:
    ///   - localization: The locale and time zone options to apply.
    ///   - format: A date format string (for example, `"yyyy-MM-dd"` or `"MMMM d, yyyy"`).
    public init(
        localization: DateLocalization,
        format: String
    ) {
        self.localization = localization
        self.format = format
    }

    /// The keys used for encoding and decoding top-level date formatter properties.
    private enum CodingKeys: String, CodingKey {
        case locale
        case timeZone
        case format
    }

    /// Initializes a new `DateFormatterOptions` by decoding from the given decoder.
    ///
    /// - Parameter decoder: The decoder to read data from.
    /// - Throws: An error if reading from the decoder fails, or if the data is corrupted or invalid.
    public init(
        from decoder: any Decoder
    ) throws {
        let container = try decoder.container(
            keyedBy: CodingKeys.self
        )

        let locale =
            try container.decodeIfPresent(
                String.self,
                forKey: .locale
            ) ?? DateLocalization.defaults.locale

        let timeZone =
            try container.decodeIfPresent(
                String.self,
                forKey: .timeZone
            ) ?? DateLocalization.defaults.timeZone

        self.localization = DateLocalization(
            locale: locale,
            timeZone: timeZone
        )
        let format = try container.decode(String.self, forKey: .format)

        guard !format.isEmpty else {
            throw DecodingError.dataCorrupted(
                .init(
                    codingPath: container.codingPath,
                    debugDescription: "Empty date format value."
                )
            )
        }
        self.format = format

    }

    /// Encodes this `DateFormatterOptions` into the given encoder.
    ///
    /// - Parameter encoder: The encoder to write data to.
    /// - Throws: An error if any values are invalid for the given encoder’s format.
    public func encode(
        to encoder: Encoder
    ) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        let defaults = DateLocalization.defaults

        if localization.locale != defaults.locale {
            try container.encode(localization.locale, forKey: .locale)
        }
        if localization.timeZone != defaults.timeZone {
            try container.encode(localization.timeZone, forKey: .timeZone)
        }
        try container.encode(format, forKey: .format)
    }
}
