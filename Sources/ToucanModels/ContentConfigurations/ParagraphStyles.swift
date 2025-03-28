//
//  ParagraphStyles.swift
//
//  Created by gerp83 on 2025. 03. 28.
//
    

public struct ParagraphStyles: Decodable, Equatable {
    
    enum CodingKeys: CodingKey {
        case note
        case warn
    }
    
    public var note: [String]
    public var warn: [String]

    // MARK: - defaults

    public static var defaults: Self {
        .init(
            note: ["note"],
            warn: ["warn", "warning"]
        )
    }
    
    // MARK: - init

    public init(
        note: [String],
        warn: [String]
    ) {
        self.note = note
        self.warn = warn
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

        self.init(
            note: note,
            warn: warn
        )
    }
    
    
}
