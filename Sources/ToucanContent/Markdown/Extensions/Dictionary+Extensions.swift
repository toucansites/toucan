//
//  Dictionary+Extensions.swift
//  Toucan
//
//  Created by Tibor Bodecs on 2025. 02. 19..
//

import Foundation
import ToucanModels
import Markdown

extension Dictionary {

    func mapKeys<Transformed>(
        _ transform: (Key) throws -> Transformed
    ) rethrows -> [Transformed: Value] {
        .init(
            uniqueKeysWithValues: try map { (try transform($0.key), $0.value) }
        )
    }
}
