//
//  StringExtensionsTestSuite.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 05. 17..
//

import Testing

@testable import ToucanCore

@Suite
struct StringExtensionsTestSuite {

    // MARK: - URL (slug) validation

    @Test
    func specifiedCharactersPass() {
        let alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
        let numerics = "0123456789"
        let special = "-._~{}%"
        let reserved = ":/?#[]@!$&'()*+,;="

        #expect(alphabet.containsOnlyValidURLCharacters())
        #expect(numerics.containsOnlyValidURLCharacters())
        #expect(special.containsOnlyValidURLCharacters())
        #expect(reserved.containsOnlyValidURLCharacters())
    }

    @Test
    func percentEncodingAllowed() {
        #expect("%".containsOnlyValidURLCharacters())
        #expect("hello%20world".containsOnlyValidURLCharacters())
    }

    @Test
    func mixedValidStringPasses() {
        #expect(
            "https://example.com/a-b_c~d.e?x=1&y=2#frag"
                .containsOnlyValidURLCharacters()
        )
    }

    @Test
    func spaceFails() {
        #expect(!"hello world".containsOnlyValidURLCharacters())
        #expect(!" ".containsOnlyValidURLCharacters())
    }

    @Test
    func nonASCIIFails() {
        #expect(!"café".containsOnlyValidURLCharacters())
        #expect(!"東京".containsOnlyValidURLCharacters())
        #expect(!"🙂".containsOnlyValidURLCharacters())
    }

    @Test
    func punctuationOutsideSpecFails() {
        #expect(!"\"".containsOnlyValidURLCharacters())
        #expect(!"<".containsOnlyValidURLCharacters())
        #expect(!"\\".containsOnlyValidURLCharacters())
        #expect(!"{|}".containsOnlyValidURLCharacters())
    }

    @Test
    func emptyURLStringIsValid() {
        #expect("".containsOnlyValidURLCharacters())
    }

    @Test
    func percentTripletStructureNotEnforced() {
        #expect("%2G".containsOnlyValidURLCharacters())
        #expect("%ZZ".containsOnlyValidURLCharacters())
    }

    // MARK: - path validation

    @Test
    func validPathCharactersPass() {
        #expect("documents/swift-guide.txt".containsOnlyValidPathCharacters())
        #expect("images/profile_photo-01.png".containsOnlyValidPathCharacters())
        #expect("{{page.iterator}}".containsOnlyValidPathCharacters())
        #expect("[01](fo_o)-bar:special".containsOnlyValidPathCharacters())
    }

    @Test
    func disallowedPercentFails() {
        #expect(!"hello%20world".containsOnlyValidPathCharacters())
    }

    @Test
    func disallowedQuestionMarkFails() {
        #expect(!"file?name.txt".containsOnlyValidPathCharacters())
    }

    @Test
    func disallowedHashFails() {
        #expect(!"docs#section".containsOnlyValidPathCharacters())
    }

    @Test
    func disallowedAmpersandFails() {
        #expect(!"a&b.txt".containsOnlyValidPathCharacters())
    }

    @Test
    func disallowedEqualsFails() {
        #expect(!"key=value".containsOnlyValidPathCharacters())
    }

    @Test
    func emptyPathStringIsValid() {
        #expect("".containsOnlyValidPathCharacters())
    }

    @Test
    func mixedValidCharactersPass() {
        #expect(
            "folder/sub-folder/file_name-123.txt"
                .containsOnlyValidPathCharacters()
        )
    }
}
