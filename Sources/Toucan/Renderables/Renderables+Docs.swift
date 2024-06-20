//
//  State+Docs.swift
//  
//
//  Created by Tibor Bodecs on 20/06/2024.
//

extension Renderables {

    struct Docs {

        struct Category {
            let list: Renderable<Output.HTML<Void>>?
            let details: [Renderable<Output.HTML<Void>>]
        }

        struct Guide {
            let list: Renderable<Output.HTML<Void>>?
            let details: [Renderable<Output.HTML<Void>>]
        }

        let home: Renderable<Output.HTML<Void>>?
        let categories: [Renderable<Output.HTML<Void>>]
        let guides: [Renderable<Output.HTML<Void>>]
    }
}
