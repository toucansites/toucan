//
//  DateFormatConfig.swift
//  toucan
//
//  Created by Viasz-Kádi Ferenc on 2025. 03. 28..
//

public struct LocalizedDateFormat: Codable, Equatable {
    
    public let locale: String?
    public let timeZone: String?
    public let format: String

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
