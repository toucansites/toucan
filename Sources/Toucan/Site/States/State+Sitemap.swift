//
//  File.swift
//
//
//  Created by Tibor Bodecs on 14/05/2024.
//

extension Site.State {

    struct Sitemap {
        
        struct URL {
            let location: String
            let lastModification: String
        }
        
        let urls: [URL]
    }
}
