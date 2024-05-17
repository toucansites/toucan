//
//  File 2.swift
//
//
//  Created by Tibor Bodecs on 10/05/2024.
//

import Foundation

struct ContentContext<T> {
    let site: SiteContext
    let metadata: MetadataContext
    let content: T
    let currentYear: String
    let userDefined: [String: String]
    
    init(
        site: SiteContext,
        metadata: MetadataContext,
        content: T,
        userDefined: [String : String]
    ) {
        let year = Calendar(identifier: .gregorian)
            .component(.year, from: Date())
        self.site = site
        self.metadata = metadata
        self.content = content
        self.currentYear = "\(year)"
        self.userDefined = userDefined
    }
}

