//
//  SystemPropertyKeys.swift
//  Toucan
//
//  Created by Ferenc Viasz-Kadi on 2025. 08. 22..
//

/// Represents predefined system property keys used throughout Toucan.
public enum SystemPropertyKeys: String, CaseIterable {
    /// Unique identifier for the object.
    case id
    /// Timestamp indicating the last modification date of the object.
    case lastUpdate
    /// URL-friendly identifier (slug) for the object.
    case slug
    /// The type or category of the object.
    case type
}