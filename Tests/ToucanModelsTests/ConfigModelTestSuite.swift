//
//  File 2.swift
//  toucan
//
//  Created by Tibor Bodecs on 2025. 01. 29..
//

import Foundation
import Testing
import ToucanDecoder
@testable import ToucanModels

@Suite
struct ConfigModelTestSuite {

    // MARK: -
    
    @Test
    func testDecodingThemeConfig() throws {
        
        let themeConfigData = """
        """.data(using: .utf8)!
        
        let decoer = ToucanYAMLDecoder()

        let themeConfig = try decoer.decode(HTMLRendererConfig.Themes.self, from: themeConfigData)

        
        print(themeConfig)
        
//        #expect(jsonString == #"{"type":"bool"}"#)
    }
}
