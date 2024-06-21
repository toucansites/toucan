//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 20/06/2024.
//

extension Context {
    
    public struct Pages {

        struct Detail {
            let page: Context.Pages.Custom
        }

        struct Custom {
            let permalink: String
            let title: String
            let description: String
            let figure: Context.Figure??
            let userDefined: [String: Any]
        }
    }
}
