//
//  String+Extensions.swift
//  Toucan
//
//  Created by Tibor Bodecs on 2025. 01. 31..
//

import Foundation

extension String {

    func trimmingBracketsContent() -> String {
        var result = ""
        var insideBrackets = false

        let decoded = self.removingPercentEncoding ?? self

        for char in decoded {
            if char == "[" {
                insideBrackets = true
            }
            else if char == "]" {
                insideBrackets = false
            }
            else if !insideBrackets {
                result.append(char)
            }
        }
        return result
    }

    var baseName: String {
        URL(fileURLWithPath: self).deletingPathExtension().lastPathComponent
    }

    var pathIdValue: String {
        var components = split(separator: "/")
            .map {
                String($0)
            }
        guard !components.isEmpty else {
            return self
        }

        if let last = components.last, last.contains(".") {
            let fileName =
                last
                .split(separator: ".")
                .dropLast()
                .joined(separator: ".")
            components.removeLast()
            components.append(fileName)
        }

        return components.joined(separator: ".")
    }
}
