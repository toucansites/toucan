//
//  File.swift
//  toucan
//
//  Created by Tibor Bodecs on 2025. 02. 12..
//

public struct DateFormats: Encodable {

    public struct Standard: Encodable {

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

        public var full: String
        public var long: String
        public var medium: String
        public var short: String
    }

    public var date: Standard
    public var time: Standard
    public var timestamp: Double
    public var formats: [String: String]

    public init(
        date: Standard,
        time: Standard,
        timestamp: Double,
        formats: [String: String]
    ) {
        self.date = date
        self.time = time
        self.timestamp = timestamp
        self.formats = formats
    }
}
