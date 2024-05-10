//
//  File 2.swift
//
//
//  Created by Tibor Bodecs on 10/05/2024.
//

struct PageContext<T> {
    let site: SiteContext
    let metadata: MetadataContext
    let content: T
}
