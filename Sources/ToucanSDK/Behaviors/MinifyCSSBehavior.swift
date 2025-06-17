//
//  MinifyCSSBehavior.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 05. 12..
//

import Foundation
import SwiftCSSParser

struct MinifyCSSBehavior: Behavior {
    static let id = "minify-css"

    func run(fileURL: URL) throws -> String {
        let src = try String(
            contentsOf: fileURL
        )
        let stylesheet = try Stylesheet.parse(from: src)
        return stylesheet.minified()
    }
}
