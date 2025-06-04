//
//  MustacheFile.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 06. 04..
//

import ToucanSerialization
import FileManagerKit
import FileManagerKitBuilder

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
        return .file(
            .init(
                name: name + "." + ext,
                string: template
            )
        )
    }
}
