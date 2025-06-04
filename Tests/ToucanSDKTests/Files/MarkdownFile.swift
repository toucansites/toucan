//
//  MarkdownFile.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 06. 04..
//

import ToucanSource
import ToucanSerialization
import FileManagerKit
import FileManagerKitBuilder

struct MarkdownFile {

    var name: String
    var ext: String
    var markdown: Markdown

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
