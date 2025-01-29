//
//  File.swift
//  ToucanV2
//
//  Created by Tibor Bodecs on 2025. 01. 21..
//

public struct Group {

    public let key: String
    public let order: Order
    
    public init(
        key: String,
        order: Order
    ) {
        self.key = key
        self.order = order
    }
}
