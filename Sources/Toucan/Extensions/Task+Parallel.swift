//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 10/06/2024.
//


extension Sequence {
    
    func parallelMapped<T>(
        concurrency: Int,
        _ t: @escaping @Sendable (Element) async throws -> T
    ) async throws -> any Sequence<T> {
        try await withThrowingTaskGroup(of: T.self) { group in
            var result: [T] = []

            var iterator = makeIterator()
            var i = 0
            while let element = iterator.next() {
                if i >= concurrency {
                    if let res = try await group.next() {
                        result.append(res)
                    }
                }
                group.addTask {
                    try await t(element)
                }
                i += 1
            }
            
            for try await res in group {
                result.append(res)
            }
            return result
        }
    }
}
