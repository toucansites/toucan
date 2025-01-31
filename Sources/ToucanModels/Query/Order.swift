//
//  order.swift
//  TestApp
//
//  Created by Tibor Bodecs on 2025. 01. 15..
//

public struct Order {

    public var key: String
    public var direction: Direction

    public init(
        key: String,
        direction: Direction = .asc
    ) {
        self.key = key
        self.direction = direction
    }
}
