//
//  File.swift
//
//
//  Created by Tibor Bodecs on 03/05/2024.
//

import Foundation

/// A static site generator.
public struct Toucan {

    //    public let inputUrl: URL
    //    public let outputUrl: URL

    /// Creates a new instance.
    public init(
        inputPath: String,
        outputPath: String
    ) {
        //        let home = FileManager.default.homeDirectoryForCurrentUser.path
        //        func getSafeUrl(_ path: String, home: String) -> URL {
        //            .init(
        //                fileURLWithPath: path.replacingOccurrences(["~": home])
        //            )
        //            .standardized
        //        }
        //        self.inputUrl = getSafeUrl(inputPath, home: home)
        //        self.outputUrl = getSafeUrl(outputPath, home: home)
    }

    /// Generates a static site.
    public func generate(
        _ baseUrl: String?
    ) throws {

    }

}
