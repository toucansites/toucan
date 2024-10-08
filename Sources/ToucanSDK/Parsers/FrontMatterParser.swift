//
//  File.swift
//
//
//  Created by Tibor Bodecs on 03/05/2024.
//

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
        return try Yaml.parse(yaml: String(rawMetadata))
    }
}
