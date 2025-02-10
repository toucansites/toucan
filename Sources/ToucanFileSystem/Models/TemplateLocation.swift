//
//  OverrideFileLocation.swift
//  toucan
//
//  Created by Tibor Bodecs on 2025. 01. 31..
//

import Foundation

public struct TemplateLocation: Equatable, Comparable {
    
    public static func < (lhs: TemplateLocation, rhs: TemplateLocation) -> Bool {
        lhs.id < rhs.id
    }
    
    let id: String
    let path: String
    
    public init(id: String, path: String) {
        self.id = id
        self.path = path
    }
}
