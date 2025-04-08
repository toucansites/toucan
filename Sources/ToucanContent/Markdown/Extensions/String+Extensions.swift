//
//  String+Extensions.swift
//  Toucan
//
//  Created by Tibor Bodecs on 2025. 02. 19..
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
        return self.hasSuffix("/") ? "" : "/"
    }

    func resolveAsset(
        baseUrl: String,
        assetsPath: String,
        slug: Slug
    ) -> String {
        if baseUrl.isEmpty || assetsPath.isEmpty {
            return self
        }

        if self.contains("{{baseUrl}}") {
            return self.replacingOccurrences(of: "{{baseUrl}}", with: baseUrl)
        }

        let prefix = "./\(assetsPath)/"
        guard self.hasPrefix(prefix) else {
            return self
        }

        let src = String(self.dropFirst(prefix.count))

        return "\(baseUrl)\(baseUrl.suffixForPath())\(assetsPath)/\(slug.resolveForPath())/\(src)"
    }
}
