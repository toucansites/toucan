//
//  CompileSASSBehavior.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 05. 12..
//

import DartSass
import Foundation

struct CompileSASSBehavior: Behavior {

    static let id = "compile-sass"

    var compiler: Compiler

    // MARK: - Lifecycle

    init() throws {
        self.compiler = try .init()
    }

    /// NOTE: This is horrible... but we can live with it for a while :)
    private func unsafeSyncCompile(fileURL: URL) -> String {
        final class Enclosure: @unchecked Sendable {
            var value: CompilerResults!
        }

        let semaphore = DispatchSemaphore(value: 0)
        let enclosure = Enclosure()

        Task {
            do {
                enclosure.value =
                    try await compiler.compile(
                        fileURL: fileURL
                    )
            }
            catch {
                fatalError("\(error) - \(fileURL.path())")
            }

            semaphore.signal()
        }

        semaphore.wait()
        return enclosure.value.css
    }

    func run(fileURL: URL) throws -> String {
        let css = unsafeSyncCompile(fileURL: fileURL)

        return css
    }
}
