import Foundation
import ArgumentParser
import ToucanSDK

extension Entrypoint {

    struct Serve: ParsableCommand {

        static var _commandName: String = "serve"
        
        @Argument(help: "The input directory (default: src).")
        var input: String = "./src"
        
        @Argument(help: "The output directory (default: docs).")
        var output: String = "./docs"
        
        @Option(name: .shortAndLong, help: "The base url to use.")
        var baseUrl: String? = nil
        
        func run() throws {
            let generator = Toucan(
                input: input,
                output: output,
                baseUrl: baseUrl
            )
            try generator.generate()
        }
    }
}
