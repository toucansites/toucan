//
//  Dictionary+Extensions.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 02. 19..
//

extension Dictionary {

    func mapKeys<T>(
        _ t: (Key) throws -> T
    ) rethrows -> [T: Value] {
        .init(
            uniqueKeysWithValues: try map { (try t($0.key), $0.value) }
        )
    }
}
