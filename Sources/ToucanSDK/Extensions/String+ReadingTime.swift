//
//  File.swift
//  toucan
//
//  Created by Viasz-Kádi Ferenc on 2024. 10. 15..
//

import Foundation

extension String {

    /// Calculates the estimated reading time for a given text, assuming an average reading speed of 238 words per minute. The result is always at least 1 minute.
    ///
    /// - Returns: Estimated reading time in minutes.
    func readingTime() -> Int {
        max(self.split(separator: " ").count / 238, 1)
    }
}
