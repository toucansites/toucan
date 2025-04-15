//
//  ParagraphStyles.swift
//  Toucan
//
//  Created by gerp83 on 2025. 03. 28.
//

public struct ParagraphStyles: Decodable, Equatable {

    enum CodingKeys: CodingKey {
        case note
        case warn
        case tip
        case important
        case error
    }

    public var note: [String]
    public var warn: [String]
    public var tip: [String]
    public var important: [String]
    public var error: [String]

    // MARK: - defaults

    public static var defaults: Self {
        .init(
            note: ["note"],
            warn: ["warn", "warning"],
            tip: ["tip"],
            important: ["important"],
            error: ["error", "caution"]
        )
    }

    // MARK: - init

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

    // MARK: - decoder

    public init(
        from decoder: any Decoder
    ) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let note =
            try container.decodeIfPresent(
                [String].self,
                forKey: .note
            ) ?? []

        let warn =
            try container.decodeIfPresent(
                [String].self,
                forKey: .warn
            ) ?? []

        let tip =
            try container.decodeIfPresent(
                [String].self,
                forKey: .tip
            ) ?? []

        let important =
            try container.decodeIfPresent(
                [String].self,
                forKey: .important
            ) ?? []

        let error =
            try container.decodeIfPresent(
                [String].self,
                forKey: .error
            ) ?? []

        self.init(
            note: note,
            warn: warn,
            tip: tip,
            important: important,
            error: error
        )
    }

}
