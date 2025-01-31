//
//  order.swift
//  TestApp
//
//  Created by Tibor Bodecs on 2025. 01. 15..
//

public struct Order {

    public let key: String
    public let direction: Direction

    public init(
        key: String,
        direction: Direction = .asc
    ) {
        self.key = key
        self.direction = direction
    }
}
