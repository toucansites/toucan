import Foundation
import Testing
import ToucanSource
import ToucanModels

@Suite
struct ContentDefinitionDecodingTestSuite {

    // MARK: - order

    @Test
    func minimal() throws {
        let data = """
            type: post
            """
            .data(using: .utf8)!

        let decoder = ToucanYAMLDecoder()

        let result = try decoder.decode(
            ContentDefinition.self,
            from: data
        )

        #expect(result.type == "post")
    }

    @Test
    func complex() throws {
        let data = """
            type: post
            properties: 
                title: 
                    type: string
                publication:
                    type: date
                    format: "y.m.d"
                    required: true
            relations:
                authors:
                    references: author
                    type: many
                    order: 
                        key: name
                tags:
                    references: tag
                    type: many
                    order: 
                        key: priority
                        sort: desc
            queries:
                prev:
                    contentType: post
                    limit: 1
                    filter:
                        key: publication
                        operator: lessThan
                        value: "{{publication}}"
                
                next:
                    contentType: post
                    limit: 1
                    filter:
                        key: publication
                        operator: greaterThan
                        value: "{{publication}}"

                related:
                    contentType: post
                    limit: 4
                    filter:
                        and:
                            - key: tags
                              operator: in
                              value: "{{tags}}"
                            
                            - key: id
                              operator: notEquals
                              value: "{{id}}"
                similar:
                    contentType: post
                    limit: 4
                    filter:
                        and:
                            - key: tags
                              operator: in
                              value: "{{tags}}"
                            
                            - key: id
                              operator: notEquals
                              value: "{{id}}"

                
            """
            .data(using: .utf8)!

        let decoder = ToucanYAMLDecoder()

        let result = try decoder.decode(
            ContentDefinition.self,
            from: data
        )

        #expect(result.type == "post")
    }
}
