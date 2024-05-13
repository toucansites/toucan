//
//  File.swift
//
//
//  Created by Tibor Bodecs on 13/05/2024.
//

struct ArrayContext<T> {

    let elements: [T]
    let hasElements: Bool

    init(_ elements: [T]) {
        self.elements = elements
        self.hasElements = !elements.isEmpty
    }
}
