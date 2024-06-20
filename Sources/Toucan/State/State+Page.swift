//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 20/06/2024.
//

extension State {
    public struct Page {

        struct Detail {
            let page: State.Page.Custom
        }

        struct Custom {
            let permalink: String
            let title: String
            let description: String
            let figure: State.Figure??
            let userDefined: [String: Any]
        }
    }
}
