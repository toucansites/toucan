//
//  File.swift
//  toucan
//
//  Created by Tibor Bodecs on 18/07/2024.
//

import Foundation

struct ContentType: Codable {
    
    enum Order: String, Codable {
        case asc
        case desc
    }

    enum Join: String, Codable {
        case one
        case many
    }

    struct Property: Codable {
        let type: String
        let required: Bool
    }
    
    struct Relation: Codable {
        let references: String
        let join: Join
        let sort: String?
        let order: Order?
        let limit: Int?
    }
    
    struct Context: Codable {
        
        struct Site: Codable {

            struct Pagination: Codable {
                let limit: Int
            }

            let sort: String?
            let order: Order?
            let pagination: Pagination?
        }
        
        struct Local: Codable {
            let references: String
            let foreignKey: String
            let sort: String?
            let order: Order?
            let limit: Int?
        }

        let site: [String: Site]?
        let local: [String: Local]?

    }

    let id: String
    let template: String?
    let properties: [String: Property]?
    let relations: [String: Relation]?
    let context: Context?
}

