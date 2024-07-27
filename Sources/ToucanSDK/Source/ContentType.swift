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

    struct Pagination: Codable {
        let bundle: String
        let limit: Int
        let sort: String?
        let order: Order?
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

    struct Filter: Codable {

        enum Method: String, Codable {
            case equals
        }

        let field: String
        let method: Method
        let value: String
    }

    struct Context: Codable {

        struct Site: Codable {
            let sort: String?
            let order: Order?
            let limit: Int?
            let filter: Filter?
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
    
    struct Transformers: Codable {
        
        struct Transformer: Codable {
            let name: String
            let options: [String: String]?
        }

        let run: [Transformer]?
        let render: Bool?
    }

    let id: String
    let rss: Bool?
    let template: String?
    let pagination: Pagination?
    let properties: [String: Property]?
    let relations: [String: Relation]?
    let context: Context?
    let transformers: Transformers?
}

extension ContentType {

    static let `default` = ContentType(
        id: "page",
        rss: nil,
        template: "pages.single.page",
        pagination: nil,
        properties: nil,
        relations: nil,
        context: .init(
            site: [
                "pages": .init(
                    sort: "title",
                    order: .asc,
                    limit: nil,
                    filter: nil
                )
            ],
            local: nil
        ),
        transformers: nil
    )
    
    static let pagination = ContentType(
        id: "pagination",
        rss: nil,
        template: "pages.single.page",
        pagination: nil,
        properties: nil,
        relations: nil,
        context: .init(
            site: [:],
            local: nil
        ),
        transformers: nil
    )
}
