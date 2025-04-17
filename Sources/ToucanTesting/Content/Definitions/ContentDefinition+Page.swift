//
//  ContentDefinition+Page.swift
//  Toucan
//
//  Created by Binary Birds on 2025. 04. 17..

import ToucanModels

public extension ContentDefinition.Mocks {

    static func page() -> ContentDefinition {
        .init(
            id: "page",
            default: true,
            paths: [
                "pages"
            ],
            properties: [
                "title": .init(
                    propertyType: .string,
                    isRequired: true,
                    defaultValue: nil
                ),
                "description": .init(
                    propertyType: .string,
                    isRequired: true,
                    defaultValue: nil
                ),
            ],
            relations: [:],
            queries: [:]
        )
    }
}
