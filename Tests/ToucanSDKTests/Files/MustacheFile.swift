//
//  MustacheFile.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 06. 04..
//

import FileManagerKit
import FileManagerKitBuilder
import ToucanSerialization

struct MustacheFile {
    var name: String
    var ext: String
    var template: String

    init(
        name: String,
        ext: String = "mustache",
        template: String
    ) {
        self.name = name
        self.ext = ext
        self.template = template
    }
}

extension MustacheFile: BuildableItem {
    func buildItem() -> FileManagerPlayground.Item {
        .file(
            .init(
                name: name + "." + ext,
                string: template
            )
        )
    }
}
