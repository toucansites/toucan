//
//  pagebundle.swift
//  TestApp
//
//  Created by Tibor Bodecs on 2025. 01. 15..
//



struct PageBundle {
    // id, slug, location (path)

    let frontMatter: [String: Any]
    var properties: [String: TypeWrapper]
}
