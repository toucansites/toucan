//
//  File.swift
//
//
//  Created by Tibor Bodecs on 03/05/2024.
//

struct MetadataParser {

    func parse(
        markdown: String
    ) -> [String: String] {
        var result: [String: String] = [:]

        guard markdown.starts(with: "---") else {
            return result
        }

        let parts = markdown.split(
            separator: "---",
            maxSplits: 1,
            omittingEmptySubsequences: true
        )

        guard let rawMetadata = parts.first else {
            return result
        }

        let lines = rawMetadata.split(
            separator: "\n",
            omittingEmptySubsequences: true
        )

        for line in lines {
            let metadataParts = line.split(
                separator: ":",
                maxSplits: 1,
                omittingEmptySubsequences: true
            )
            guard metadataParts.count == 2 else {
                continue
            }

            let key = metadataParts[0]
                .trimmingCharacters(
                    in: .whitespaces
                )
            let value = metadataParts[1]
                .trimmingCharacters(
                    in: .whitespaces
                )

            result[key] = value
        }
        return result
    }
}
