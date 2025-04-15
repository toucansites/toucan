//
//  PrettyPrint.swift
//  Toucan
//
//  Created by Tibor Bodecs on 2025. 02. 11..
//

import Foundation
@testable import ToucanModels

public func prettyPrint(_ object: [String: AnyCodable]) {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [
        .prettyPrinted,
        .withoutEscapingSlashes,
        //.sortedKeys,
    ]

    do {
        let data = try encoder.encode(object)

        guard
            let dataString = String(
                data: data,
                encoding: .utf8
            )
        else {
            return
        }
        print(dataString)
    }
    catch {
        print("\(error)")
        fatalError(error.localizedDescription)
    }

}
