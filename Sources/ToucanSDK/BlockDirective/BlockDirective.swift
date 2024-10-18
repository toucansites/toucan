//
//  File.swift
//  toucan
//
//  Created by Tibor Bodecs on 18/07/2024.
//

import Foundation

struct Block: Codable {

    struct Param: Codable {
        let label: String
        let required: Bool?
        let `default`: String?
    }

    struct Attribute: Codable {
        let name: String
        let value: String
    }

    let name: String
    let params: [Param]?
    let requiresParentDirective: String?
    let removesChildParagraph: Bool?
    let tag: String?
    let attributes: [Attribute]?
    let output: String?
}
