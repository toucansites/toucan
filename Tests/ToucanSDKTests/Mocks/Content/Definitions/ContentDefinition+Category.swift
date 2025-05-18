//
//  ContentDefinition+Category.swift
//  Toucan
//
//  Created by Binary Birds on 2025. 04. 17..

//public extension ContentDefinition.Mocks {
//
//    static func category() -> ContentDefinition {
//        .init(
//            id: "category",
//            paths: [
//                "docs/categories"
//            ],
//            properties: [
//                "title": .init(
//                    propertyType: .string,
//                    isRequired: true,
//                    defaultValue: nil
//                ),
//                "order": .init(
//                    propertyType: .int,
//                    isRequired: false,
//                    defaultValue: .init(100)
//                ),
//            ],
//            relations: [:],
//            queries: [
//                "guides": .init(
//                    contentType: "guide",
//                    scope: "list",
//                    limit: 100,
//                    offset: 0,
//                    filter: .field(
//                        key: "category",
//                        operator: .equals,
//                        value: .init("{{id}}")
//                    ),
//                    orderBy: [
//                        .init(key: "order", direction: .desc)
//                    ]
//                )
//            ]
//        )
//    }
//}
