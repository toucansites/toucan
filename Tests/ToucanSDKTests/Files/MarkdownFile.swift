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
import Foundation

struct MarkdownFile {

    var name: String
    var ext: String
    var markdown: Markdown
    var modificationDate: Date

    init(
        name: String,
        ext: String = "md",
        markdown: Markdown,
        modificationDate: Date = .now
    ) {
        self.name = name
        self.ext = ext
        self.markdown = markdown
        self.modificationDate = modificationDate
    }
}

extension MarkdownFile: BuildableItem {

    func buildItem() -> FileManagerPlayground.Item {
        let encoder = ToucanYAMLEncoder()
        let yml = try! encoder.encode(markdown.frontMatter)
        return .file(
            .init(
                name: name + "." + ext,
                attributes: [.modificationDate: modificationDate],
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
