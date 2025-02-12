//
//  File.swift
//  toucan
//
//  Created by Tibor Bodecs on 2025. 02. 11..
//

import Foundation
import ToucanModels
import ToucanCodable

public func prettyPrint(_ object: [String: AnyCodable]) {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [
        .prettyPrinted,
        .withoutEscapingSlashes,
//        .sortedKeys,
    ]

    do {
        let data = try encoder.encode(object)
        
        guard
            let jsonString = String(
                data: data,
                encoding: .utf8
            )
        else {
            return
        }
        print(jsonString)
    }
    catch {
        print("\(error)")
        fatalError(error.localizedDescription)
    }
    
    
}
