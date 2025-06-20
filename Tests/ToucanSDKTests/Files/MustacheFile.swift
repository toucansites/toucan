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
    var contents: String

    init(
        name: String,
        ext: String = "mustache",
        contents: String
    ) {
        self.name = name
        self.ext = ext
        self.contents = contents
    }
}

extension MustacheFile: BuildableItem {

    func buildItem() -> FileManagerPlayground.Item {
        .file(
            .init(
                name: name + "." + ext,
                string: contents
            )
        )
    }
}
