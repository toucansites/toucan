//
//  RawContentBundle.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 06. 04..
//

import ToucanSource
import ToucanSerialization
import FileManagerKit
import FileManagerKitBuilder

struct RawContentBundle {

    var rawContent: RawContent

    init(
        _ rawContent: RawContent
    ) {
        self.rawContent = rawContent
    }
}

extension RawContentBundle: BuildableItem {

    func buildItem() -> FileManagerPlayground.Item {
        .directory(
            Directory(name: rawContent.origin.slug) {
                Directory(name: "assets") {
                    for asset in rawContent.assets {
                        File(name: asset, string: asset)
                    }
                }
                MarkdownFile(
                    name: "index",
                    markdown: rawContent.markdown
                )
            }
        )
    }
}
