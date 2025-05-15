//
//  String+Extensions.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 02. 19..
//

import Foundation
import ToucanModels
import Markdown

public extension String {

    func replacingOccurrences(
        _ dictionary: [String: String]
    ) -> String {
        var result = self
        for (key, value) in dictionary {
            result = result.replacingOccurrences(of: key, with: value)
        }
        return result
    }

    func replacingFirstOccurrence(
        of target: Character?,
        with replacement: String
    ) -> String {
        guard let target, let index = firstIndex(of: target)
        else {
            return self
        }

        var modified = self
        modified.replaceSubrange(index...index, with: replacement)
        return modified
    }

    func slugify() -> String {
        let allowed = CharacterSet(
            charactersIn: "abcdefghijklmnopqrstuvwxyz0123456789-_."
        )
        return trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
            .folding(
                options: .diacriticInsensitive,
                locale: .init(identifier: "en-US")
            )
            .components(separatedBy: allowed.inverted)
            .filter { $0 != "" }
            .joined(separator: "-")
    }

    func suffixForPath() -> String {
        hasSuffix("/") ? "" : "/"
    }

    func resolveAsset(
        baseUrl: String,
        assetsPath: String,
        slug: Slug
    ) -> String {
        if baseUrl.isEmpty || assetsPath.isEmpty {
            return self
        }

        if contains("{{baseUrl}}") {
            let baseUrlPath = baseUrl + baseUrl.suffixForPath()
            var value = self
            if let slashIndex = firstIndex(of: "/") {
                let offset = distance(
                    from: startIndex,
                    to: slashIndex
                )
                if offset == 11 {
                    value = value.replacingFirstOccurrence(of: "/", with: "")
                }
            }
            return value.replacingOccurrences(
                of: "{{baseUrl}}",
                with: baseUrlPath
            )
        }

        let prefix = "./\(assetsPath)/"
        guard hasPrefix(prefix) else {
            return self
        }

        let src = String(dropFirst(prefix.count))

        return [
            "\(baseUrl)\(baseUrl.suffixForPath())\(assetsPath)",
            slug.value,
            src,
        ]
        .filter { !$0.isEmpty }.joined(separator: "/")
    }
}
