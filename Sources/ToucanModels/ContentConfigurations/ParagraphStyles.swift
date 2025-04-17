//
//  ParagraphStyles.swift
//  Toucan
//
//  Created by gerp83 on 2025. 04. 17..
//

/// Defines paragraph style aliases for block-level directives
public struct ParagraphStyles: Codable, Equatable {

    // MARK: - Coding Keys

    private enum CodingKeys: CodingKey {
        case note
        case warn
        case tip
        case important
        case error
    }

    // MARK: - Properties

    /// Aliases for informational notes
    public var note: [String]

    /// Aliases for warnings
    public var warn: [String]

    /// Aliases for tips
    public var tip: [String]

    /// Aliases for important information
    public var important: [String]

    /// Aliases for error messages or cautionary content
    public var error: [String]

    // MARK: - Defaults

    /// Returns a standard `ParagraphStyles` configuration with common alias values.
    public static var defaults: Self {
        .init(
            note: ["note"],
            warn: ["warn", "warning"],
            tip: ["tip"],
            important: ["important"],
            error: ["error", "caution"]
        )
    }

    // MARK: - Initialization

    /// Initializes a `ParagraphStyles` object with custom alias mappings.
    ///
    /// - Parameters:
    ///   - note: Aliases for the "note" style.
    ///   - warn: Aliases for the "warn" style.
    ///   - tip: Aliases for the "tip" style.
    ///   - important: Aliases for the "important" style.
    ///   - error: Aliases for the "error" style.
    public init(
        note: [String],
        warn: [String],
        tip: [String],
        important: [String],
        error: [String]
    ) {
        self.note = note
        self.warn = warn
        self.tip = tip
        self.important = important
        self.error = error
    }

    // MARK: - Decoding

    /// Decodes a `ParagraphStyles` configuration from input,
    /// with missing fields defaulting to empty arrays.
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let note =
            try container.decodeIfPresent([String].self, forKey: .note) ?? []
        let warn =
            try container.decodeIfPresent([String].self, forKey: .warn) ?? []
        let tip =
            try container.decodeIfPresent([String].self, forKey: .tip) ?? []
        let important =
            try container.decodeIfPresent([String].self, forKey: .important)
            ?? []
        let error =
            try container.decodeIfPresent([String].self, forKey: .error) ?? []

        self.init(
            note: note,
            warn: warn,
            tip: tip,
            important: important,
            error: error
        )
    }
}
