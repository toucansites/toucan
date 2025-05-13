//
//  CompileSASSBehavior.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 05. 12..
//

import Foundation
import DartSass

struct CompileSASSBehavior {

    var compiler: Compiler

    init() throws {
        self.compiler = try .init()
    }

    func compile(fileUrl: URL) throws -> String {

        let css = unsafeSyncCompile(fileUrl: fileUrl)

        return css
    }

    /// NOTE: This is horrible... but we can live with it for a while :)
    private func unsafeSyncCompile(fileUrl: URL) -> String {

        final class Enclosure: @unchecked Sendable {
            var value: CompilerResults!
        }

        let semaphore = DispatchSemaphore(value: 0)
        let enclosure = Enclosure()

        Task {
            do {
                enclosure.value =
                    try await compiler.compile(
                        fileURL: fileUrl
                    )
            }
            catch {
                fatalError("\(error) - \(fileUrl.path())")
            }

            semaphore.signal()
        }

        semaphore.wait()
        return enclosure.value.css
    }
}
