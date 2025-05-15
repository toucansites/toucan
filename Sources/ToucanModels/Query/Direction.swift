//
//  Direction.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 01. 21..
//

/// Represents the direction for sorting query results: ascending or descending.
public enum Direction: String, Decodable, Equatable {

    /// Sort in ascending order (e.g., A–Z, 1–9).
    case asc

    /// Sort in descending order (e.g., Z–A, 9–1).
    case desc

    /// The default sorting direction. Defaults to `.asc`.
    public static var defaults: Self {
        .asc
    }
}
