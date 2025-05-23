//
//  BuildTargetSourceValidatorTestSuite.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 05. 23..
//
//
import Foundation
import Testing
import Logging
import ToucanCore
import ToucanSource
import ToucanSerialization
@testable import ToucanSDK

@Suite
struct BuildTargetSourceValidatorTestSuite {

    @Test
    func duplicateDefaultContentTypes() throws {
        let now = Date()
        let buildTargetSource = BuildTargetSource(
            location: .init(filePath: ""),
            target: .standard,
            config: .defaults,
            settings: .defaults,
            pipelines: [],
            contentDefinitions: [
                .init(
                    id: "foo",
                    default: true,
                    paths: [],
                    properties: [:],
                    relations: [:],
                    queries: [:]
                ),
                .init(
                    id: "bar",
                    default: true,
                    paths: [],
                    properties: [:],
                    relations: [:],
                    queries: [:]
                ),
            ],
            rawContents: [],
            blockDirectives: []
        )
        let encoder = ToucanYAMLEncoder()
        let decoder = ToucanYAMLDecoder()

        let validator = BuildTargetSourceValidator(
            buildTargetSource: buildTargetSource
        )

        do {
            try validator.validate()
        }
        catch {
            guard case .multipleDefaultContentTypes(let values) = error else {
                Issue.record("Invalid error.")
                return
            }
            #expect(values == ["foo", "bar"].sorted())
        }

        //        catch let error as ToucanError {
        //            print(error.logMessageStack())
        //            if let context = error.lookup({
        //                if case DecodingError.dataCorrupted(let ctx) = $0 {
        //                    return ctx
        //                }
        //                return nil
        //            }) {
        //                let expected = "The given data was not valid YAML."
        //                #expect(context.debugDescription == expected)
        //            }
        //            else {
        //                throw error
        //            }
        //        }
    }

}
