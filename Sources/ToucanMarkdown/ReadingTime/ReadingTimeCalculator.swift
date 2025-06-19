//
//  ReadingTimeCalculator.swift
//  Toucan
//
//  Created by Viasz-Kádi Ferenc on 2024. 10. 15..
//

import Logging

/// A utility to estimate the reading time of a given string of text based on words per minute.
public struct ReadingTimeCalculator {
    /// The number of words assumed to be read per minute.
    public var wordsPerMinute: Int

    /// Logger instance
    public var logger: Logger

    // MARK: - Lifecycle

    /// Initializes a new instance of `ReadingTimeCalculator`.
    ///
    /// - Parameters:
    ///   - wordsPerMinute: The number of words a person can read per minute. Defaults to 238.
    ///   - logger: A `Logger` instance for logging internal operations. Defaults to a logger labeled "ReadingTimeCalculator".
    public init(
        wordsPerMinute: Int = 238,
        logger: Logger = .init(label: "ReadingTimeCalculator")
    ) {
        self.wordsPerMinute = wordsPerMinute
        self.logger = logger
    }

    // MARK: - Functions

    /// Calculates the estimated reading time for a given string.
    ///
    /// - Parameter string: The input text to estimate reading time for.
    /// - Returns: An estimated reading time in minutes. Returns at least 1 minute.
    public func calculate(
        for string: String
    ) -> Int {
        max(string.split(separator: " ").count / wordsPerMinute, 1)
    }
}
