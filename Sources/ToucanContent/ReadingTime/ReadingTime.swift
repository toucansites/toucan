//
//  File.swift
//  toucan
//
//  Created by Viasz-Kádi Ferenc on 2024. 10. 15..
//

public struct ReadingTime {

    public var wordsPerMinute: Int

    public init(
        wordsPerMinute: Int = 238
    ) {
        self.wordsPerMinute = wordsPerMinute
    }

    public func calculate(
        for string: String
    ) -> Int {
        max(string.split(separator: " ").count / wordsPerMinute, 1)
    }
}
