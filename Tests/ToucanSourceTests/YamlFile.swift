//
//  YamlFile.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 05. 20..
//

import ToucanSerialization
import FileManagerKit
import FileManagerKitTesting

struct YAML<T: Encodable> {

    var name: String
    var ext: String
    var contents: T

    init(
        name: String,
        ext: String = "yml",
        contents: T
    ) {
        self.name = name
        self.ext = ext
        self.contents = contents
    }

    var file: File {
        let encoder = ToucanYAMLEncoder()
        return .init(
            name + "." + ext,
            string: try! encoder.encode(contents)
        )
    }
}
