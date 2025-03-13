//
//  File.swift
//  toucan
//
//  Created by Tibor Bodecs on 2025. 02. 19..
//

import Foundation
import Markdown

extension Dictionary {

    func mapKeys<Transformed>(
        _ transform: (Key) throws -> Transformed
    ) rethrows -> [Transformed: Value] {
        .init(
            uniqueKeysWithValues: try map { (try transform($0.key), $0.value) }
        )
    }
}

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
                locale: .init(identifier: "en_US")
            )
            .components(separatedBy: allowed.inverted)
            .filter { $0 != "" }
            .joined(separator: "-")
    }
    
    func resolveAsset(baseUrl: String, assetsPath: String, slug: String) -> String {
        if baseUrl.isEmpty || assetsPath.isEmpty {
            return self
        }
        
        if self.contains("{{baseUrl}}"){
            return self.replacingOccurrences(of: "{{baseUrl}}", with: baseUrl)
        }
        
        let prefix = "./\(assetsPath)/"
        guard self.hasPrefix(prefix) else {
            return self
        }

        let src = String(self.dropFirst(prefix.count))
        
        return "\(baseUrl)\(baseUrl.hasSuffix("/") ? "" : "/")\(assetsPath)/\(slug.isEmpty ? "home" : slug)/\(src)"
    }
}

extension HTMLVisitor {
    
    func imageOverride(_ image: Image) -> String? {
        guard
            let source = image.source
        else {
            return nil
        }
        let path = source.resolveAsset(baseUrl: baseUrl, assetsPath: assetsPath, slug: slug)
        
        var title = ""
        if let ttl = image.title {
            title = #" title="\#(ttl)""#
        }
        return """
        <img src="\(path)" alt="\(image.plainText)"\(title)>
        """
    }
    
}
