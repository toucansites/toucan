//
//  ReservedFrontMatterParser.swift
//  Toucan
//
//  Created by Viasz-Kádi Ferenc on 2025. 03. 04..
//

//import ToucanModels

//struct ReservedFrontMatterParser {
//
//    let decoder: ToucanDecoder
//
//    func parse(_ contents: String) throws -> ReservedFrontMatter {
//        guard contents.starts(with: "---") else {
//            return .empty()
//        }
//
//        let parts = contents.split(
//            separator: "---",
//            maxSplits: 1,
//            omittingEmptySubsequences: true
//        )
//
//        guard let rawMetadata = parts.first else {
//            return .empty()
//        }
//
//        return try decoder.decode(
//            ReservedFrontMatter.self,
//            from: String(rawMetadata).dataValue()
//        )
//    }
//}
