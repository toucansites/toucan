//
//  File.swift
//
//
//  Created by Tibor Bodecs on 03/05/2024.
//

import Yams

struct FrontMatterParser {

    func parse(
        markdown: String
    ) throws -> [String: Any] {
        guard markdown.starts(with: "---") else {
            return [:]
        }

        let parts = markdown.split(
            separator: "---",
            maxSplits: 1,
            omittingEmptySubsequences: true
        )

        guard let rawMetadata = parts.first else {
            return [:]
        }
        return try load(yaml: String(rawMetadata))
    }
    
    func load(
        yaml: String
    ) throws -> [String: Any] {
        try load(yaml: yaml, as: [String: Any].self) ?? [:]
    }

    func load<T>(
        yaml: String,
        as: T.Type
    ) throws -> T? {
        try Yams.load(
            yaml: String(yaml),
            Resolver.default.removing(.timestamp)
        ) as? T
    }
}
