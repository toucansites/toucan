//
//  LocalizedDateFormat.swift
//  Toucan
//
//  Created by Viasz-Kádi Ferenc on 2025. 03. 28..
//

/// A structure representing a locale-aware date format configuration,
/// including optional locale and time zone settings for formatting dates.
public struct LocalizedDateFormat: Sendable, Codable, Equatable {

    /// The locale identifier used for formatting (e.g., `"en_US"`, `"fr_FR"`).
    /// If `nil`, the system’s default locale will be used.
    public let locale: String?

    /// The time zone identifier (e.g., `"UTC"`, `"Europe/Budapest"`).
    /// If `nil`, the system’s default time zone will be used.
    public let timeZone: String?

    /// The date format string (e.g., `"yyyy-MM-dd"`, `"MMMM d, yyyy"`).
    public let format: String

    /// Initializes a new `LocalizedDateFormat` with an optional locale and time zone.
    ///
    /// - Parameters:
    ///   - locale: An optional locale identifier for localization.
    ///   - timeZone: An optional time zone identifier.
    ///   - format: A format string for date output.
    public init(
        locale: String? = nil,
        timeZone: String? = nil,
        format: String
    ) {
        self.locale = locale
        self.timeZone = timeZone
        self.format = format
    }
}
