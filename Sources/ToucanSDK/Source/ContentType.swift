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
        enum DataType: String, Codable, CaseIterable {
            case string
            case int
            case double
            case bool
            case date
            case array
            case object
        }

        let type: DataType
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
    let location: String?
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
        location: nil,
        template: "pages.single.page",
        pagination: nil,
        properties: [
            :
            //            "type": .init(
            //                type: .string,
            //                required: false
            //            ),
            //            "slug": .init(
            //                type: .string,
            //                required: false
            //            ),
            //            "title": .init(
            //                type: .string,
            //                required: false
            //            ),
            //            "description": .init(
            //                type: .string,
            //                required: false
            //            ),
            //            "image": .init(
            //                type: .string,
            //                required: false
            //            ),
            //            "draft": .init(
            //                type: .bool,
            //                required: false
            //            ),
            //            "publication": .init(
            //                type: .date,
            //                required: false
            //            ),
            //            "expiration": .init(
            //                type: .date,
            //                required: false
            //            ),
            //case template
            //case output
            //case assets
            //case redirects
            //
            //case noindex
            //case canonical
            //case hreflang
            //case css
            //case js

        ],
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
        location: nil,
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
