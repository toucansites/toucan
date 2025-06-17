//
//  HTML.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 02. 19..
//

struct HTML {
    enum TagType {
        case standard
        case short
    }

    struct Attribute {
        var key: String
        var value: String
    }

    var name: String
    var type: TagType
    var attributes: [Attribute]
    var contents: String?

    init(
        name: String,
        type: TagType = .standard,
        attributes: [Attribute] = [],
        contents: String? = nil
    ) {
        self.name = name
        self.type = type
        self.attributes = attributes
        self.contents = contents
    }

    func render() -> String {
        let attributeString =
            attributes
            .map { #"\#($0.key)="\#($0.value)""# }
            .joined(separator: " ")

        let tag = [name, attributeString]
            .filter { !$0.isEmpty }
            .joined(separator: " ")

        var result = "<\(tag)>"
        result += contents ?? ""
        if type == .standard {
            result += "</\(name)>"
        }
        return result
    }
}
