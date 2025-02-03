//
//  File.swift
//  toucan
//
//  Created by Tibor Bodecs on 2025. 02. 03..
//

import Foundation

func prettyPrint(_ object: Any) {
    guard
        let data = try? JSONSerialization.data(
            withJSONObject: object,
            options: [
                .prettyPrinted,
                .withoutEscapingSlashes,
            ]
        ),
        let jsonString = String(
            data: data,
            encoding: .utf8
        )
    else {
        return
    }
    print(jsonString)
}
