import Foundation
import ArgumentParser
import ToucanSDK

extension Entrypoint {

    struct Generate: AsyncParsableCommand {

        @Argument(help: "The input directory (default: src).")
        var input: String = "./src"

        @Argument(help: "The output directory (default: docs).")
        var output: String = "./docs"

        @Option(name: .shortAndLong, help: "The base url to use.")
        var baseUrl: String? = nil

        func run() async throws {
            let generator = Toucan(
                input: input,
                output: output,
                baseUrl: baseUrl
            )
            try generator.generate()
        }
    }
}
