//
//  MinifyCSSBehavior.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 05. 12..
//

import Foundation
import SwiftCSSParser

struct MinifyCSSBehavior {

    func minify(fileUrl: URL) throws -> String {
        let src = try String(
            contentsOf: fileUrl
        )
        let stylesheet = try Stylesheet.parse(from: src)
        return stylesheet.minified()
    }

}
