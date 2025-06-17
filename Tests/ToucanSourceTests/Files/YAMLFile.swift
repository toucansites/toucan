//
//  YAMLFile.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 05. 20..
//

import FileManagerKit
import FileManagerKitBuilder
import ToucanSerialization

struct YAMLFile<T: Encodable> {
    // MARK: - Properties

    var name: String
    var ext: String
    var contents: T

    // MARK: - Lifecycle

    init(
        name: String,
        ext: String = "yml",
        contents: T
    ) {
        self.name = name
        self.ext = ext
        self.contents = contents
    }
}

extension YAMLFile: BuildableItem {
    func buildItem() -> FileManagerPlayground.Item {
        let encoder = ToucanYAMLEncoder()
        return .file(
            .init(
                name: name + "." + ext,
                string: try! encoder.encode(contents)
            )
        )
    }
}
