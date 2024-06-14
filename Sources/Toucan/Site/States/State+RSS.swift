//
//  File.swift
//
//
//  Created by Tibor Bodecs on 14/05/2024.
//

extension Site.State {
    
    struct RSS {
        
        struct Item {
            let permalink: String
            let title: String
            let description: String
            let publicationDate: String
        }
        
        let title: String
        let description: String
        let baseUrl: String
        let language: String?
        let lastBuildDate: String
        let publicationDate: String
        let items: [Item]
    }
}
