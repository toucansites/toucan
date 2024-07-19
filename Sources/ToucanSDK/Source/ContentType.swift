//
//  File.swift
//  toucan
//
//  Created by Tibor Bodecs on 18/07/2024.
//

import Foundation

struct ContentType: Codable {
    
    struct Context: Codable {
        
        enum Order: String, Codable {
            case asc
            case desc
        }

        enum Join: String, Codable {
            case one
            case many
        }
        
        struct Pagination: Codable {
            let limit: Int
        }
        
        struct Site: Codable {
            let sort: String
            let order: Order
            let pagination: Pagination
        }
        
        struct Page: Codable {
            let references: String
            let using: String
            let join: Join
            let sort: String
            let order: Order
            let limit: Int?
        }
        
        struct Relation: Codable {
            let references: String
            let join: Join
            let sort: String
            let order: Order
            let limit: Int?
        }


        let site: [String: Site]?
        let page: [String: Page]?
        let relations: [String: Relation]?
    }

    
    let id: String
    let context: Context?
    let template: String
    let properties: [String]
}
