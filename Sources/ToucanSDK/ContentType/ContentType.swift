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
        }

        let type: DataType
        let defaultValue: String?
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

    let id: String
    let api: String?
    let rss: Bool?
    let location: String?
    let template: String?
    let css: [String]?
    let js: [String]?
    let pagination: Pagination?
    let properties: [String: Property]?
    let relations: [String: Relation]?
    let context: Context?
}

extension ContentType {

    var propertyKeys: [String] {
        properties?.keys.sorted() ?? []
    }

    var relationKeys: [String] {
        relations?.keys.sorted() ?? []
    }
}

extension ContentType {

    static let `default` = ContentType(
        id: "page",
        api: "pages",
        rss: nil,
        location: nil,
        template: "pages.default",
        css: nil,
        js: nil,
        pagination: nil,
        properties: [:],
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
        )
    )

    static let pagination = ContentType(
        id: "pagination",
        api: nil,
        rss: nil,
        location: nil,
        template: "pages.default",
        css: nil,
        js: nil,
        pagination: nil,
        properties: nil,
        relations: nil,
        context: .init(
            site: [:],
            local: nil
        )
    )
}
