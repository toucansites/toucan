//
//  MarkdownFile.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 06. 04..
//

import FileManagerKit
import FileManagerKitBuilder
import ToucanSerialization
import ToucanSource

struct MarkdownFile {
    // MARK: - Properties

    var name: String
    var ext: String
    var markdown: Markdown

    // MARK: - Lifecycle

    init(
        name: String,
        ext: String = "md",
        markdown: Markdown
    ) {
        self.name = name
        self.ext = ext
        self.markdown = markdown
    }
}

extension MarkdownFile: BuildableItem {
    func buildItem() -> FileManagerPlayground.Item {
        let encoder = ToucanYAMLEncoder()
        let yml = try! encoder.encode(markdown.frontMatter)
        return .file(
            .init(
                name: name + "." + ext,
                string: """
                    ---
                    \(yml)
                    ---
                    \(markdown.contents)
                    """
            )
        )
    }
}
