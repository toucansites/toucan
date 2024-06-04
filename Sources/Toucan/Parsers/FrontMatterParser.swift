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
        return try Yams.load(
            yaml: String(rawMetadata),
            Resolver.default.removing(.timestamp)
        ) as? [String: Any] ?? [:]
    }
}
