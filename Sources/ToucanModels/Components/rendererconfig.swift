//
//  rendererconfig.swift
//  TestApp
//
//  Created by Tibor Bodecs on 2025. 01. 16..
//



struct RendererConfig {
    
    struct Template {
        let engine: String
        let options: [String: Any]
        let output: String
    }

   
    struct Renders: OptionSet {
        let rawValue: UInt

        static let pageBundle = Renders(rawValue: 1 << 0)
        static let contentBundle = Renders(rawValue: 1 << 0)

        static let all: Renders = [
            pageBundle, contentBundle
        ]
    }
    
    
    let queries: [String: Query]
    let renders: Renders
    let template: Template
}

