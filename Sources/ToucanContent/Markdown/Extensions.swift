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

extension String {

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
}

extension HTMLVisitor {
    
    func imageOverride(_ image: Image) -> String? {
        guard
            let source = image.source
        else {
            return nil
        }
        let path = resolveAsset(path: source)
        
        var title = ""
        if let ttl = image.title {
            title = #" title="\#(ttl)""#
        }
        return """
        <img src="\(path)" alt="\(image.plainText)"\(title)>
        """
    }
    
    func resolveAsset(path: String) -> String {
        if baseUrl.isEmpty || assetsPath.isEmpty {
            return path
        }
        
        print("baseUrl", baseUrl)
        print("assetsPath", assetsPath)
        print("slug", slug)
        
        if path.contains("{{baseUrl}}"){
            return path.replacingOccurrences(of: "{{baseUrl}}", with: baseUrl)
        }
        
        let prefix = "./\(assetsPath)/"
        guard path.hasPrefix(prefix) else {
            return path
        }

        let src = String(path.dropFirst(prefix.count))

        return "\(baseUrl)/\(assetsPath)/\(slug.isEmpty ? "home" : slug)/\(src)"
            .replacingOccurrences(of: "//", with: "/")
    }
    
}
