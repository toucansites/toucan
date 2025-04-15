//
//  ReadingTimeCalculator.swift
//  Toucan
//
//  Created by Viasz-Kádi Ferenc on 2024. 10. 15..
//

import Logging

public struct ReadingTimeCalculator {

    public var wordsPerMinute: Int
    public var logger: Logger

    public init(
        wordsPerMinute: Int = 238,
        logger: Logger = .init(label: "ReadingTimeCalculator")
    ) {
        self.wordsPerMinute = wordsPerMinute
        self.logger = logger
    }

    public func calculate(
        for string: String
    ) -> Int {
        max(string.split(separator: " ").count / wordsPerMinute, 1)
    }
}
