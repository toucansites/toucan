//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 20/06/2024.
//

extension Context {
    
    public struct Pages {

        struct Home {
            let pages: [Pages.Item]
        }

        struct DetailPage {
            let page: Context.Pages.Item
        }

        struct Item {
            let slug: String
            let permalink: String
            let title: String
            let description: String
            let imageUrl: String?
        }
    }
}
