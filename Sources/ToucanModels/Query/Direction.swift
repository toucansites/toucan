//
//  File.swift
//  ToucanV2
//
//  Created by Tibor Bodecs on 2025. 01. 21..
//

public enum Direction: String, Decodable, Equatable {
    case asc
    case desc

    public static var defaults: Direction {
        .asc
    }
}
