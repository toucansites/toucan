//
//  ContentDefinition+Author.swift
//  Toucan
//
//  Created by Binary Birds on 2025. 04. 17..

import ToucanModels

public extension ContentDefinition.Mocks {

    static func author(isDefault: Bool = false) -> ContentDefinition {
        .init(
            id: "author",
            default: isDefault,
            paths: [
                "blog/authors"
            ],
            properties: [
                "name": .init(
                    propertyType: .string,
                    isRequired: true,
                    defaultValue: nil
                ),
                "description": .init(
                    propertyType: .string,
                    isRequired: false,
                    defaultValue: nil
                ),
                "age": .init(
                    propertyType: .int,
                    isRequired: false,
                    defaultValue: nil
                ),
                "height": .init(
                    propertyType: .double,
                    isRequired: false,
                    defaultValue: nil
                ),
            ],
            relations: [:],
            queries: [
                "posts": .init(
                    contentType: "post",
                    scope: "list",
                    limit: 100,
                    offset: 0,
                    filter: .field(
                        key: "authors",
                        operator: .contains,
                        value: .init("{{id}}")
                    ),
                    orderBy: [
                        .init(key: "publication", direction: .desc)
                    ]
                )
            ]
        )
    }
}
