//
//  ContentDefinition+Guide.swift
//  Toucan
//
//  Created by Binary Birds on 2025. 04. 17..

import ToucanModels

public extension ContentDefinition.Mocks {

    static func guide() -> ContentDefinition {
        .init(
            id: "guide",
            paths: [
                "docs/guides"
            ],
            properties: [
                "title": .init(
                    propertyType: .string,
                    isRequired: true,
                    defaultValue: nil
                ),
                "order": .init(
                    propertyType: .int,
                    isRequired: false,
                    defaultValue: .init(100)
                ),
            ],
            relations: [
                "category": .init(
                    references: "category",
                    relationType: .one,
                    order: .init(key: "name", direction: .asc)
                )
            ],
            queries: [:]
        )
    }
}
