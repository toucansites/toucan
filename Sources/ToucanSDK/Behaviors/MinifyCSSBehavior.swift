//
//  MinifyCSSBehavior.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 05. 12..
//

import Foundation
import SwiftCSSParser

struct MinifyCSSBehavior: Behavior {
    // MARK: - Static Properties

    static let id = "minify-css"

    // MARK: - Functions

    func run(fileURL: URL) throws -> String {
        let src = try String(
            contentsOf: fileURL
        )
        let stylesheet = try Stylesheet.parse(from: src)
        return stylesheet.minified()
    }
}
