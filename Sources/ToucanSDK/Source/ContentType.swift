//
//  File.swift
//  toucan
//
//  Created by Tibor Bodecs on 18/07/2024.
//

import Foundation

struct ContentType: Codable {
    
    struct Context: Codable {
        
        struct List: Codable {
            enum Order: String, Codable {
                case asc
                case desc
            }
            
            struct Pagination: Codable {
                let limit: Int
            }
            
            let name: String
            let sort: String
            let order: Order
            let pagination: Pagination
        }

        let list: List?
    }

    
    let id: String
    let context: Context?
    let template: String
    let properties: [String]
}

