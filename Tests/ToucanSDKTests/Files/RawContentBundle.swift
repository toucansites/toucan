//
//  RawContentBundle.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 06. 04..
//

import FileManagerKit
import FileManagerKitBuilder
import ToucanSerialization
import ToucanSource

struct RawContentBundle {
    var name: String
    var rawContent: RawContent
}

extension RawContentBundle: BuildableItem {
    func buildItem() -> FileManagerPlayground.Item {
        .directory(
            Directory(name: name) {
                Directory(name: rawContent.assetsPath) {
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
