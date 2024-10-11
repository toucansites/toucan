//
//  File.swift
//  toucan
//
//  Created by Viasz-Kádi Ferenc on 2024. 10. 10..
//

import Foundation

extension Array {

    /// Appends the given item to the collection if no element in the collection satisfies the specified condition.
    ///
    /// - Parameters:
    ///   - item: The element to be appended to the collection if the condition is not met.
    ///   - condition: A closure that takes an element of the collection as its argument and returns a Boolean value indicating whether the element satisfies the condition.
    mutating func appendIfNot(
        _ item: Element,
        where condition: (Element) -> Bool
    ) {
        if !contains(where: condition) {
            append(item)
        }
    }
}
