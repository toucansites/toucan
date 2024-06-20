//
//  State+Main.swift
//  
//
//  Created by Tibor Bodecs on 20/06/2024.
//

extension Renderables {
    
    struct Main {
        let home: Renderable<Output.HTML<State.Main.Home>>
        let notFound: Renderable<Output.HTML<Void>>
        let rss: Renderable<Output.RSS>
        let sitemap: Renderable<Output.Sitemap>
    }
    
}
